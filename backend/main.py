from __future__ import annotations

import certifi
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from typing import Optional

import os
import shutil
import asyncio
import time
from bson import ObjectId
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext
from pydantic import BaseModel, EmailStr, Field

import google.generativeai as genai
from dotenv import load_dotenv
import os
# Setup Gemini AI
load_dotenv()

API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise Exception("Thiếu GEMINI_API_KEY")

genai.configure(api_key=API_KEY)
# for m in genai.list_models():
#     print(m.name, m.supported_generation_methods)
# ── Cấu hình MongoDB ──────────────────────────────────────────────────────────
# Mặc định kết nối MongoDB cài local.
# Nếu dùng MongoDB Atlas, thay bằng connection string của Atlas:
#   MONGO_URL = "mongodb+srv://<user>:<password>@cluster.mongodb.net/"
MONGO_URL = "mongodb://localhost:27017"
DB_NAME = "ky_nang_song"

# ── Password hashing ──────────────────────────────────────────────────────────
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ── Pydantic models ───────────────────────────────────────────────────────────
class UserInRegister(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=128)


class UserInLogin(BaseModel):
    email: EmailStr
    password: str


class UserPublic(BaseModel):
    id: str
    name: str
    email: EmailStr
    role: str = "user"
    avatar_url: Optional[str] = None


class RoleUpdate(BaseModel):
    admin_id: str
    target_email: str
    new_role: str


# ── MongoDB lifespan ─────────────────────────────────────────────────────────
mongo_client: Optional[AsyncIOMotorClient] = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Khởi động và dọn dẹp kết nối MongoDB Local."""
    global mongo_client

    mongo_client = AsyncIOMotorClient(
        MONGO_URL,
        serverSelectionTimeoutMS=5000
    )

    try:
        await mongo_client.admin.command("ping")
        print("✅ Kết nối MongoDB LOCAL thành công!")
    except Exception as e:
        print(f"❌ Lỗi: Bạn đã bật MongoDB Service chưa? Chi tiết: {e}")

    db = mongo_client[DB_NAME]
    await db.users.create_index("email", unique=True)

    yield
    mongo_client.close()


# ── FastAPI app ───────────────────────────────────────────────────────────────
app = FastAPI(title="Ky Nang Song Auth API - MongoDB", lifespan=lifespan)

os.makedirs("static/avatars", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_users_collection():
    return mongo_client[DB_NAME]["users"]


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(password: str, hashed: str) -> bool:
    return pwd_context.verify(password, hashed)


def _is_gemini_quota_error(error: Exception) -> bool:
    message = str(error).lower()
    return any(
        marker in message
        for marker in [
            "429",
            "quota",
            "rate limit",
            "resource exhausted",
            "too many requests",
        ]
    )


def _build_local_ai_fallback(query: str) -> str:
    query_lower = query.lower()

    def contains_any(words: list[str]) -> bool:
        return any(word in query_lower for word in words)

    if contains_any(["cháy", "lửa", "hỏa hoạn", "cháy nhà", "bốc khói"]):
        return (
            "✅ **Tình huống:** Nhà cháy cần ưu tiên thoát nạn an toàn trước.\n"
            "⚠️ **Điều cần tránh:** Không quay lại lấy đồ, không dùng thang máy, không hoảng loạn chạy ngược dòng người.\n"
            "📌 **Các bước xử lý:**\n"
            "- Báo động cho mọi người và gọi 114 ngay.\n"
            "- Cúi thấp, che mũi miệng bằng khăn ướt nếu có khói.\n"
            "- Di chuyển theo lối thoát hiểm gần nhất, tránh chen lấn.\n"
            "💡 **Lời khuyên thêm:** Nếu quần áo bén lửa, hãy dừng lại, nằm xuống và lăn người để dập lửa."
        )

    if contains_any(["máu", "cấp cứu", "thương", "ngất", "sơ cứu", "đuối nước", "bỏng"]):
        return (
            "✅ **Tình huống:** Đây có thể là tình huống cần sơ cứu nhanh.\n"
            "⚠️ **Điều cần tránh:** Không tự ý di chuyển nạn nhân nếu nghi chấn thương nặng.\n"
            "📌 **Các bước xử lý:**\n"
            "- Đảm bảo an toàn khu vực trước.\n"
            "- Gọi 115 nếu có dấu hiệu nguy hiểm.\n"
            "- Cầm máu hoặc đặt nạn nhân nằm nghiêng nếu ngất.\n"
            "💡 **Lời khuyên thêm:** Theo dõi nhịp thở và ý thức trong khi chờ hỗ trợ."
        )

    if contains_any([
        "tiền",
        "tài chính",
        "ngân hàng",
        "lừa đảo",
        "tiết kiệm",
        "chi tiêu",
        "ngân sách",
        "quỹ",
        "thu nhập",
        "đi chợ",
        "trả góp",
    ]):
        if contains_any(["chi tiêu", "ngân sách", "2 triệu", "2tr", "mỗi tháng", "tháng", "budget"]):
            return (
                "✅ **Tình huống:** Bạn đang cần chia ngân sách chi tiêu theo tháng.\n"
                "⚠️ **Điều cần tránh:** Đừng chia tiền theo cảm tính hoặc tiêu hết ở đầu tháng.\n"
                "📌 **Các bước xử lý:**\n"
                "- Trừ trước tiền cố định: ăn uống, đi lại, nhà ở, học tập.\n"
                "- Chia 2 triệu thành các nhóm nhỏ, ví dụ: thiết yếu, phát sinh, tiết kiệm.\n"
                "- Ghi lại chi tiêu mỗi ngày để biết khoản nào đang vượt mức.\n"
                "💡 **Lời khuyên thêm:** Nếu muốn, mình có thể giúp bạn chia thử 2 triệu/tháng thành một bảng cụ thể."
            )

        return (
            "✅ **Tình huống:** Đây là vấn đề tài chính cần xử lý thận trọng.\n"
            "⚠️ **Điều cần tránh:** Không chuyển tiền ngay hoặc cung cấp OTP cho người lạ.\n"
            "📌 **Các bước xử lý:**\n"
            "- Kiểm tra lại nguồn thông tin và giao dịch.\n"
            "- Đổi mật khẩu, bật xác thực 2 lớp nếu nghi lộ tài khoản.\n"
            "- Liên hệ ngân hàng nếu có dấu hiệu lừa đảo.\n"
            "💡 **Lời khuyên thêm:** Ghi lại toàn bộ bằng chứng giao dịch để xử lý sau."
        )

    if contains_any(["deadline", "hạn chót", "áp lực", "stress", "căng thẳng", "quá tải", "thi", "bài tập", "nộp bài", "không kịp"]):
        return (
            "✅ **Tình huống:** Bạn đang bị áp lực deadline hoặc quá tải việc cần làm.\n"
            "⚠️ **Điều cần tránh:** Đừng cố làm mọi thứ cùng lúc hoặc thức trắng liên tục.\n"
            "📌 **Các bước xử lý:**\n"
            "- Liệt kê toàn bộ việc cần làm, rồi chọn 1 việc quan trọng nhất trước.\n"
            "- Chia việc lớn thành các bước 15-30 phút.\n"
            "- Làm theo nhịp: tập trung 25 phút, nghỉ 5 phút.\n"
            "💡 **Lời khuyên thêm:** Nếu bạn muốn, mình có thể giúp bạn lập kế hoạch trong 1 ngày hoặc 1 tuần."
        )

    if contains_any(["giao tiếp", "thuyết trình", "tự tin", "đám đông", "phỏng vấn", "nói trước lớp"]):
        return (
            "✅ **Tình huống:** Bạn đang cần xử lý áp lực giao tiếp hoặc thuyết trình.\n"
            "⚠️ **Điều cần tránh:** Đừng cố nói quá nhanh hoặc ôm quá nhiều ý cùng lúc.\n"
            "📌 **Các bước xử lý:**\n"
            "- Chia nội dung thành 3 ý chính.\n"
            "- Thở chậm 3-5 nhịp trước khi bắt đầu.\n"
            "- Luyện nói trước gương hoặc ghi âm thử.\n"
            "💡 **Lời khuyên thêm:** Tập trung vào thông điệp chính thay vì cố hoàn hảo."
        )

    return (
        "✅ **Tình huống:** Mình chưa thể gọi Gemini lúc này nên tạm trả lời theo quy tắc cục bộ.\n"
        "⚠️ **Điều cần tránh:** Không bỏ qua các nguy cơ an toàn hoặc thông tin không chắc chắn.\n"
        "📌 **Các bước xử lý:**\n"
        "- Mô tả ngắn gọn hoàn cảnh bạn đang gặp.\n"
        "- Ưu tiên an toàn trước, rồi mới xử lý tiếp.\n"
        "- Nếu cần, mình sẽ hướng dẫn từng bước cụ thể.\n"
        "💡 **Lời khuyên thêm:** Bạn có thể gửi lại câu hỏi ngắn hơn để mình hỗ trợ đúng hơn."
    )

# ── API Endpoints ─────────────────────────────────────────────────────────────
@app.post("/api/auth/register", response_model=UserPublic)
async def register(body: UserInRegister):
    print("🔹 Register request received:", body)
    col = get_users_collection()

    # Kiểm tra email đã tồn tại
    existing = await col.find_one({"email": body.email})
    if existing:
        raise HTTPException(
            status_code=409,
            detail="Email này đã được đăng ký, vui lòng dùng email khác."
        )

    # Tạo document mới
    new_user = {
        "name": body.name,
        "email": body.email,
        "password_hash": hash_password(body.password),
        "created_at": datetime.now(timezone.utc).isoformat(),
        "role": "user",
    }

    result = await col.insert_one(new_user)
    user_id = str(result.inserted_id)
    print("🔹 New user created with id:", user_id)
    return UserPublic(id=user_id, name=body.name, email=body.email, role="user", avatar_url=None)


@app.post("/api/auth/login", response_model=UserPublic)
async def login(body: UserInLogin):
    print("🔹 Login request received:", body)
    col = get_users_collection()
    user = await col.find_one({"email": body.email})
    print("🔹 Query result:", user)
    if not user or not verify_password(body.password, user["password_hash"]):
        raise HTTPException(
            status_code=401,
            detail="Email hoặc mật khẩu không đúng."
        )

    return UserPublic(
        id=str(user["_id"]),
        name=user["name"],
        email=user["email"],
        role=user.get("role", "user"),
        avatar_url=user.get("avatar_url"),
    )

@app.post("/api/users/{user_id}/avatar")
async def upload_avatar(user_id: str, file: UploadFile = File(...)):
    col = get_users_collection()
    user = await col.find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=404, detail="Người dùng không tồn tại")
        
    ext = file.filename.split(".")[-1]
    filename = f"{user_id}_{int(datetime.now(timezone.utc).timestamp())}.{ext}"
    filepath = f"static/avatars/{filename}"
    
    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    avatar_url = f"/static/avatars/{filename}"
    await col.update_one({"_id": ObjectId(user_id)}, {"$set": {"avatar_url": avatar_url}})
    return {"avatar_url": avatar_url}


@app.get("/api/admin/users")
async def get_all_users(admin_id: str):
    col = get_users_collection()
    
    # Check quyền admin
    admin = await col.find_one({"_id": ObjectId(admin_id)})
    if not admin or admin.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Không có quyền truy cập.")
        
    users_cursor = col.find({}, {"password_hash": 0})
    users = await users_cursor.to_list(length=1000)
    return [
        {
            "id": str(u["_id"]),
            "name": u.get("name"),
            "email": u.get("email"),
            "role": u.get("role", "user")
        }
        for u in users
    ]


@app.post("/api/admin/set_role")
async def set_role(body: RoleUpdate):
    col = get_users_collection()
    
    # Check quyền admin
    admin = await col.find_one({"_id": ObjectId(body.admin_id)})
    if not admin or admin.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Không có quyền truy cập.")
        
    # Cập nhật role
    result = await col.update_one(
        {"email": body.target_email},
        {"$set": {"role": body.new_role}}
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng này.")
        
    return {"status": "success"}

# ── API Tin tức & Vui học ──────────────────────────────────────────────────────

@app.get("/api/news")
async def get_news(sort: str = "new"):
    col = mongo_client[DB_NAME]["news"]
    sort_field = "created_at"
    cursor = col.find().sort(sort_field, -1)
    news_items = await cursor.to_list(length=100)
    result = [
        {
            "id": str(n["_id"]),
            "title": n.get("title", ""),
            "summary": n.get("summary", ""),
            "content": n.get("content", ""),
            "image_url": n.get("image_url", ""),
            "created_at": n.get("created_at", ""),
            "author": n.get("author", "Admin")
        } for n in news_items
    ]
    if sort == "hot":
        import random
        random.shuffle(result)
    return result

@app.get("/api/skills")
async def get_skills():
    col = mongo_client[DB_NAME]["skills"]
    cursor = col.find().sort("created_at", -1)
    skills = await cursor.to_list(length=100)
    return [
        {
            "id": str(s["_id"]),
            "title": s.get("title", ""),
            "category": s.get("category", ""),
            "description": s.get("description", ""),
            "image_url": s.get("image_url", ""),
            "content": s.get("content", ""),
            "duration_minutes": s.get("duration_minutes", 5)
        } for s in skills
    ]

@app.get("/api/fun")
async def get_fun():
    col = mongo_client[DB_NAME]["fun"]
    cursor = col.find().sort("created_at", -1)
    fun_items = await cursor.to_list(length=100)
    return [
        {
            "id": str(f["_id"]),
            "title": f.get("title", ""),
            "type": f.get("type", "video"),
            "media_url": f.get("media_url", ""),
            "content": f.get("content", ""),
            "created_at": f.get("created_at", ""),
        } for f in fun_items
    ]

@app.get("/api/health")
async def health():
    """Kiểm tra trạng thái server và MongoDB."""
    try:
        await mongo_client.admin.command("ping")
        return {"status": "ok", "database": "MongoDB connected"}
    except Exception as e:
        return {"status": "error", "database": str(e)}


# ── Community & CMS Pydantic Models ──────────────────────────────────────────
class LikeRequest(BaseModel):
    user_id: str

class ReportRequest(BaseModel):
    user_id: str

class PostCreate(BaseModel):
    user_id: str
    user_name: str
    content: str = Field(..., min_length=1, max_length=2000)
    topic: str = "Chung"

class CommentCreate(BaseModel):
    user_id: str
    user_name: str
    content: str = Field(..., min_length=1, max_length=500)

class SkillUpsert(BaseModel):
    admin_id: str
    title: str
    category: str = "Kỹ năng chung"
    description: str
    image_url: str = ""
    content: str
    duration_minutes: int = 5

class NewsUpsert(BaseModel):
    admin_id: str
    title: str
    summary: str
    content: str
    image_url: str = ""
    author: str = "Admin"

class FunUpsert(BaseModel):
    admin_id: str
    title: str
    type: str = "tip"
    media_url: str = ""
    content: str


# ── Helper ────────────────────────────────────────────────────────────────────
def _serialize_post(p: dict) -> dict:
    pid = p.get("_id")
    return {
        "id": str(pid) if pid else p.get("id", ""),
        "user_id": p.get("user_id", ""),
        "user_name": p.get("user_name", ""),
        "content": p.get("content", ""),
        "topic": p.get("topic", "Chung"),
        "likes": p.get("likes", []),
        "likes_count": p.get("likes_count", 0),
        "comments_count": p.get("comments_count", 0),
        "reported_by": p.get("reported_by", []),
        "created_at": p.get("created_at", ""),
        "is_pinned": p.get("is_pinned", False),
        "is_hidden": p.get("is_hidden", False),
    }

async def _check_admin(admin_id: str):
    col = mongo_client[DB_NAME]["users"]
    try:
        admin = await col.find_one({"_id": ObjectId(admin_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="admin_id không hợp lệ")
    if not admin or admin.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Không có quyền truy cập.")


# ── Community API ─────────────────────────────────────────────────────────────
@app.get("/api/community/posts")
async def get_posts(sort: str = "new"):
    col = mongo_client[DB_NAME]["posts"]
    sort_field = "likes_count" if sort == "hot" else "created_at"
    cursor = col.find({"is_hidden": {"$ne": True}}).sort(sort_field, -1)
    posts = await cursor.to_list(length=200)
    return [_serialize_post(p) for p in posts]

@app.post("/api/community/posts")
async def create_post(body: PostCreate):
    col = mongo_client[DB_NAME]["posts"]
    doc = {
        "user_id": body.user_id,
        "user_name": body.user_name,
        "content": body.content,
        "topic": body.topic,
        "likes": [],
        "likes_count": 0,
        "comments_count": 0,
        "reported_by": [],
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    }
    result = await col.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _serialize_post(doc)

@app.post("/api/community/posts/{post_id}/like")
async def toggle_like(post_id: str, body: LikeRequest):
    col = mongo_client[DB_NAME]["posts"]
    post = await col.find_one({"_id": ObjectId(post_id)})
    if not post:
        raise HTTPException(status_code=404, detail="Bài đăng không tồn tại")
    likes = post.get("likes", [])
    if body.user_id in likes:
        likes.remove(body.user_id)
    else:
        likes.append(body.user_id)
    await col.update_one(
        {"_id": ObjectId(post_id)},
        {"$set": {"likes": likes, "likes_count": len(likes)}}
    )
    return {"liked": body.user_id in likes, "likes_count": len(likes)}

@app.post("/api/community/posts/{post_id}/report")
async def report_post(post_id: str, body: ReportRequest):
    col = mongo_client[DB_NAME]["posts"]
    post = await col.find_one({"_id": ObjectId(post_id)})
    if not post:
        raise HTTPException(status_code=404, detail="Bài đăng không tồn tại")
    reported = post.get("reported_by", [])
    if body.user_id not in reported:
        reported.append(body.user_id)
        await col.update_one({"_id": ObjectId(post_id)}, {"$set": {"reported_by": reported}})
    return {"status": "reported"}

@app.get("/api/community/posts/{post_id}/comments")
async def get_comments(post_id: str):
    col = mongo_client[DB_NAME]["comments"]
    cursor = col.find({"post_id": post_id}).sort("created_at", 1)
    comments = await cursor.to_list(length=500)
    return [
        {
            "id": str(c["_id"]),
            "user_id": c.get("user_id", ""),
            "user_name": c.get("user_name", ""),
            "content": c.get("content", ""),
            "reported_by": c.get("reported_by", []),
            "created_at": c.get("created_at", ""),
        }
        for c in comments
    ]

@app.post("/api/community/posts/{post_id}/comments")
async def add_comment(post_id: str, body: CommentCreate):
    posts_col = mongo_client[DB_NAME]["posts"]
    comments_col = mongo_client[DB_NAME]["comments"]
    
    try:
        obj_id = ObjectId(post_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Mã bài đăng không hợp lệ (không phải dạng chuẩn)")
        
    post = await posts_col.find_one({"_id": obj_id})
    if not post:
        raise HTTPException(status_code=404, detail="Bài đăng không tồn tại")
    doc = {
        "post_id": post_id,
        "user_id": body.user_id,
        "user_name": body.user_name,
        "content": body.content,
        "reported_by": [],
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    result = await comments_col.insert_one(doc)
    await posts_col.update_one({"_id": ObjectId(post_id)}, {"$inc": {"comments_count": 1}})
    doc.pop("_id", None)
    return {"id": str(result.inserted_id), **doc}

@app.post("/api/community/comments/{comment_id}/report")
async def report_comment(comment_id: str, body: ReportRequest):
    col = mongo_client[DB_NAME]["comments"]
    comment = await col.find_one({"_id": ObjectId(comment_id)})
    if not comment:
        raise HTTPException(status_code=404, detail="Bình luận không tồn tại")
    reported = comment.get("reported_by", [])
    if body.user_id not in reported:
        reported.append(body.user_id)
        await col.update_one({"_id": ObjectId(comment_id)}, {"$set": {"reported_by": reported}})
    return {"status": "reported"}

@app.delete("/api/community/posts/{post_id}")
async def delete_post(post_id: str, admin_id: str):
    await _check_admin(admin_id)
    col = mongo_client[DB_NAME]["posts"]
    await col.delete_one({"_id": ObjectId(post_id)})
    # Also delete comments of this post
    await mongo_client[DB_NAME]["comments"].delete_many({"post_id": post_id})
    return {"status": "deleted"}

@app.get("/api/admin/community/posts")
async def admin_get_posts(admin_id: str):
    await _check_admin(admin_id)
    col = mongo_client[DB_NAME]["posts"]
    cursor = col.find().sort("created_at", -1)
    posts = await cursor.to_list(length=500)
    return [_serialize_post(p) for p in posts]

@app.post("/api/admin/community/posts/{post_id}/toggle_hide")
async def toggle_hide_post(post_id: str, admin_id: str):
    await _check_admin(admin_id)
    col = mongo_client[DB_NAME]["posts"]
    post = await col.find_one({"_id": ObjectId(post_id)})
    if not post:
        raise HTTPException(status_code=404, detail="Không tìm thấy bài đăng")
    new_hidden = not post.get("is_hidden", False)
    await col.update_one({"_id": ObjectId(post_id)}, {"$set": {"is_hidden": new_hidden}})
    return {"is_hidden": new_hidden}


# ── Admin CMS — Skills ────────────────────────────────────────────────────────
@app.post("/api/admin/skills")
async def create_skill(body: SkillUpsert):
    await _check_admin(body.admin_id)
    col = mongo_client[DB_NAME]["skills"]
    doc = {
        "title": body.title, "category": body.category,
        "description": body.description, "image_url": body.image_url,
        "content": body.content, "duration_minutes": body.duration_minutes,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    result = await col.insert_one(doc)
    return {"id": str(result.inserted_id), **doc}

@app.put("/api/admin/skills/{skill_id}")
async def update_skill(skill_id: str, body: SkillUpsert):
    await _check_admin(body.admin_id)
    col = mongo_client[DB_NAME]["skills"]
    result = await col.update_one({"_id": ObjectId(skill_id)}, {"$set": {
        "title": body.title, "category": body.category,
        "description": body.description, "image_url": body.image_url,
        "content": body.content, "duration_minutes": body.duration_minutes,
    }})
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Không tìm thấy kỹ năng")
    return {"status": "updated"}

@app.delete("/api/admin/skills/{skill_id}")
async def delete_skill(skill_id: str, admin_id: str):
    await _check_admin(admin_id)
    await mongo_client[DB_NAME]["skills"].delete_one({"_id": ObjectId(skill_id)})
    return {"status": "deleted"}


# ── Admin CMS — News ──────────────────────────────────────────────────────────
@app.post("/api/admin/news")
async def create_news(body: NewsUpsert):
    await _check_admin(body.admin_id)
    col = mongo_client[DB_NAME]["news"]
    doc = {
        "title": body.title, "summary": body.summary, "content": body.content,
        "image_url": body.image_url, "author": body.author,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    result = await col.insert_one(doc)
    return {"id": str(result.inserted_id), **doc}

@app.put("/api/admin/news/{news_id}")
async def update_news(news_id: str, body: NewsUpsert):
    await _check_admin(body.admin_id)
    col = mongo_client[DB_NAME]["news"]
    result = await col.update_one({"_id": ObjectId(news_id)}, {"$set": {
        "title": body.title, "summary": body.summary, "content": body.content,
        "image_url": body.image_url, "author": body.author,
    }})
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Không tìm thấy tin tức")
    return {"status": "updated"}

@app.delete("/api/admin/news/{news_id}")
async def delete_news(news_id: str, admin_id: str):
    await _check_admin(admin_id)
    await mongo_client[DB_NAME]["news"].delete_one({"_id": ObjectId(news_id)})
    return {"status": "deleted"}


# ── Admin CMS — Fun ───────────────────────────────────────────────────────────
@app.post("/api/admin/fun")
async def create_fun(body: FunUpsert):
    await _check_admin(body.admin_id)
    col = mongo_client[DB_NAME]["fun"]
    doc = {
        "title": body.title, "type": body.type,
        "media_url": body.media_url, "content": body.content,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    result = await col.insert_one(doc)
    return {"id": str(result.inserted_id), **doc}

@app.put("/api/admin/fun/{fun_id}")
async def update_fun(fun_id: str, body: FunUpsert):
    await _check_admin(body.admin_id)
    col = mongo_client[DB_NAME]["fun"]
    result = await col.update_one({"_id": ObjectId(fun_id)}, {"$set": {
        "title": body.title, "type": body.type,
        "media_url": body.media_url, "content": body.content,
    }})
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Không tìm thấy nội dung")
    return {"status": "updated"}

@app.delete("/api/admin/fun/{fun_id}")
async def delete_fun(fun_id: str, admin_id: str):
    await _check_admin(admin_id)
    await mongo_client[DB_NAME]["fun"].delete_one({"_id": ObjectId(fun_id)})
    return {"status": "deleted"}

# ── AI Copilot API ────────────────────────────────────────────────────────────

class ChatRequest(BaseModel):
    query: str
    user_id: str

@app.post("/api/ai/chat")
async def ai_chat(body: ChatRequest):
    if not body.query or not body.query.strip():
        raise HTTPException(status_code=400, detail="Query rỗng")

    query = body.query.strip()
    prompt = (
        "Bạn là AI Life Skill Copilot cho sinh viên Việt Nam. "
        "Trả lời ngắn gọn, thực tiễn, bằng tiếng Việt. "
        "Nếu có thể, dùng Markdown ngắn gọn với 3 phần: Tình huống, Điều cần tránh, Các bước xử lý. "
        f"Câu hỏi: {query}"
    )

    start_time = time.monotonic()
    print(f"AI START | user_id={body.user_id} | query={query}")

    try:
        model = genai.GenerativeModel("models/gemini-2.0-flash")

        loop = asyncio.get_running_loop()
        ai_started_at = time.monotonic()
        response = await loop.run_in_executor(
            None,
            lambda: model.generate_content(prompt)
        )
        ai_elapsed = time.monotonic() - ai_started_at
        print(f"AI END | user_id={body.user_id} | seconds={ai_elapsed:.2f}")

        answer = response.text.strip() if getattr(response, "text", None) else "Không có phản hồi từ AI."

        related_skills = []
        try:
            mongo_started_at = time.monotonic()
            query_lower = query.lower()
            search_keywords = []

            if any(w in query_lower for w in ["cháy", "lửa", "hỏa hoạn"]):
                search_keywords.extend(["cháy", "hỏa hoạn", "sơ cứu"])
            elif any(w in query_lower for w in ["máu", "cấp cứu", "thương", "ngất", "sơ cứu"]):
                search_keywords.extend(["sơ cứu", "máu", "thương"])
            elif any(w in query_lower for w in ["tiền", "tài chính", "ngân hàng", "lừa đảo", "tiết kiệm", "chi tiêu"]):
                search_keywords.extend(["tài chính", "ngân hàng", "lừa đảo"])
            elif any(w in query_lower for w in ["giao tiếp", "thuyết trình", "căng thẳng", "stress", "tự tin", "đám đông"]):
                search_keywords.extend(["giao tiếp", "thuyết trình", "tự tin"])
            else:
                search_keywords.extend(query_lower.split()[:3])

            if mongo_client is not None and search_keywords:
                skills_col = mongo_client[DB_NAME]["skills"]
                regex_pattern = "|".join([k for k in search_keywords if len(k) > 2])

                if regex_pattern:
                    cursor = skills_col.find({
                        "$or": [
                            {"title": {"$regex": regex_pattern, "$options": "i"}},
                            {"description": {"$regex": regex_pattern, "$options": "i"}},
                        ]
                    }).limit(2)

                    skills = await cursor.to_list(length=2)
                    related_skills = [
                        {
                            "id": str(s["_id"]),
                            "title": s.get("title"),
                            "image_url": s.get("image_url"),
                            "category": s.get("category"),
                        }
                        for s in skills
                    ]

            mongo_elapsed = time.monotonic() - mongo_started_at
            print(f"MONGO END | user_id={body.user_id} | seconds={mongo_elapsed:.2f}")

        except Exception as e:
            print(f"MONGO ERROR | user_id={body.user_id} | error={e}")
            related_skills = []

        total_elapsed = time.monotonic() - start_time
        print(f"AI DONE | user_id={body.user_id} | total_seconds={total_elapsed:.2f}")

        return {"answer": answer, "related_skills": related_skills}

    except Exception as e:
        total_elapsed = time.monotonic() - start_time
        if _is_gemini_quota_error(e):
            print(f"AI QUOTA | user_id={body.user_id} | seconds={total_elapsed:.2f} | error={e}")
            return {
                "answer": _build_local_ai_fallback(query),
                "related_skills": [],
            }

        print(f"AI ERROR | user_id={body.user_id} | seconds={total_elapsed:.2f} | error={e}")
        return {
            "answer": f"Lỗi AI: {str(e)}",
            "related_skills": [],
        }

