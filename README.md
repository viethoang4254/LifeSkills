# Kỹ Năng Sống 4.0 - Backend API 🔧

Python FastAPI backend cho ứng dụng Kỹ Năng Sống 4.0.

---

## 📋 Mục Lục

- [Giới Thiệu](#giới-thiệu)
- [Yêu Cầu](#yêu-cầu)
- [Cài Đặt](#cài-đặt)
- [Cấu Trúc Thư Mục](#cấu-trúc-thư-mục)
- [API Endpoints](#api-endpoints)
- [Database](#database)
- [Authentication](#authentication)
- [Phát Triển](#phát-triển)

---

## 🎯 Giới Thiệu

Backend cung cấp RESTful API cho ứng dụng Flutter frontend. Xây dựng bằng **FastAPI** với **MongoDB** database.

### Stack Công Nghệ

- **Framework**: FastAPI 0.115.6+
- **Database**: MongoDB
- **Async Driver**: Motor 3.6.0
- **Authentication**: JWT + Passlib (bcrypt)
- **AI Integration**: Google Generative AI
- **Server**: Uvicorn 0.34.0+

---

## 💻 Yêu Cầu

- **Python**: 3.8+
- **MongoDB**: Local hoặc cloud instance
- **pip**: Python package manager

---

## 🚀 Cài Đặt

### 1. Clone Repository

```bash
git clone <repository-url>
cd KyNangSong4.0/backend
```

### 2. Tạo Virtual Environment

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### 3. Cài Đặt Dependencies

```bash
pip install -r requirements.txt
```

### 4. Cấu Hình Environment

Tạo file `.env`:

```
DATABASE_URL=mongodb://localhost:27017/ky_nang_song
SECRET_KEY=your_super_secret_key_here_change_in_production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
GOOGLE_API_KEY=your_google_generativeai_key
DEBUG=True
```

### 5. Seed Database (Optional)

```bash
python seed_data.py
```

### 6. Tạo Admin User

```bash
python make_admin.py
```

### 7. Chạy Server

```bash
# Development
python main.py

# Hoặc
uvicorn main:app --reload

# Production
gunicorn -w 4 -b 0.0.0.0:8000 main:app
```

✅ Server chạy tại: `http://localhost:8000`
📚 API Docs: `http://localhost:8000/docs`

---

## 📁 Cấu Trúc Thư Mục

```
backend/
├── main.py                 # FastAPI app & routes
├── requirements.txt        # Python dependencies
├── seed_data.py           # Database seeding script
├── make_admin.py          # Create admin user script
├── start.bat              # Windows startup script
├── data/
│   └── users.json         # Sample user data
└── README.md              # This file
```

---

## 🔌 API Endpoints

### Base URL

```
http://localhost:8000/api
```

### Authentication Endpoints

```
POST   /auth/register           # Đăng ký tài khoản
POST   /auth/login              # Đăng nhập
POST   /auth/logout             # Đăng xuất
POST   /auth/refresh            # Refresh token
GET    /auth/me                 # Thông tin hiện tại
```

### User Endpoints

```
GET    /users                   # Danh sách người dùng
GET    /users/{id}              # Thông tin người dùng
PUT    /users/{id}              # Cập nhật thông tin
DELETE /users/{id}              # Xóa người dùng
GET    /users/ranking           # Bảng xếp hạng
```

### Skills Endpoints

```
GET    /skills                  # Danh sách kỹ năng
GET    /skills/{id}             # Chi tiết kỹ năng
POST   /skills                  # Tạo kỹ năng (Admin)
PUT    /skills/{id}             # Cập nhật kỹ năng (Admin)
DELETE /skills/{id}             # Xóa kỹ năng (Admin)
```

### Courses Endpoints

```
GET    /courses                 # Danh sách khoá học
GET    /courses/{id}            # Chi tiết khoá học
POST   /courses                 # Tạo khoá học (Admin)
PUT    /courses/{id}            # Cập nhật khoá học (Admin)
DELETE /courses/{id}            # Xóa khoá học (Admin)
POST   /courses/{id}/enroll    # Đăng ký khoá học
```

### Posts Endpoints

```
GET    /posts                   # Danh sách bài viết
GET    /posts/{id}              # Chi tiết bài viết
POST   /posts                   # Tạo bài viết
PUT    /posts/{id}              # Cập nhật bài viết
DELETE /posts/{id}              # Xóa bài viết
POST   /posts/{id}/comment     # Bình luận
```

### News Endpoints

```
GET    /news                    # Danh sách tin tức
GET    /news/{id}               # Chi tiết tin tức
POST   /news                    # Tạo tin tức (Admin)
PUT    /news/{id}               # Cập nhật tin tức (Admin)
DELETE /news/{id}               # Xóa tin tức (Admin)
```

### AI Endpoints

```
POST   /ai/chat                 # Chat với AI
GET    /ai/history              # Lịch sử chat
DELETE /ai/history              # Xóa lịch sử
```

### Community Endpoints

```
GET    /community/posts         # Bài viết cộng đồng
GET    /community/members       # Danh sách thành viên
POST   /community/join          # Tham gia cộng đồng
```

### Admin Endpoints (Admin only)

```
GET    /admin/stats             # Thống kê hệ thống
GET    /admin/users             # Quản lý người dùng
GET    /admin/logs              # Logs hệ thống
POST   /admin/send-notification # Gửi thông báo
```

---

## 📊 Database

### MongoDB Collections

#### users

```json
{
  "_id": ObjectId,
  "email": "user@example.com",
  "username": "username",
  "password_hash": "bcrypt_hash",
  "first_name": "John",
  "last_name": "Doe",
  "avatar_url": "url",
  "role": "user|admin",
  "is_active": true,
  "skills": [ObjectId],
  "enrolled_courses": [ObjectId],
  "progress": {
    "course_id": 45,  # percentage
    "skill_id": 80
  },
  "created_at": ISODate,
  "updated_at": ISODate
}
```

#### skills

```json
{
  "_id": ObjectId,
  "name": "Communication",
  "description": "...",
  "icon": "url",
  "category": "soft-skills",
  "level": "beginner",
  "content": "...",
  "created_at": ISODate
}
```

#### courses

```json
{
  "_id": ObjectId,
  "title": "Course Title",
  "description": "...",
  "skill_id": ObjectId,
  "lessons": [
    {
      "id": 1,
      "title": "Lesson 1",
      "content": "..."
    }
  ],
  "created_at": ISODate
}
```

#### posts

```json
{
  "_id": ObjectId,
  "author_id": ObjectId,
  "title": "Post Title",
  "content": "...",
  "image": "url",
  "likes": 10,
  "comments": [ObjectId],
  "created_at": ISODate
}
```

---

## 🔐 Authentication

### JWT Token Flow

1. **Register**: User cung cấp email/password

   ```
   POST /auth/register
   {
     "email": "user@example.com",
     "password": "password123"
   }
   ```

2. **Login**: Nhận access token

   ```
   POST /auth/login
   {
     "email": "user@example.com",
     "password": "password123"
   }
   Response:
   {
     "access_token": "jwt_token",
     "token_type": "bearer"
   }
   ```

3. **Use Token**: Include trong header

   ```
   Authorization: Bearer <access_token>
   ```

4. **Refresh**: Lấy token mới
   ```
   POST /auth/refresh
   ```

### Password Security

- Bcrypt hashing với salt rounds = 12
- Min 8 characters, contains uppercase, lowercase, numbers
- Change password requires current password verification

---

## 🛠️ Phát Triển

### Run Development Server

```bash
uvicorn main:app --reload
```

### File Structure

```
main.py
├── Pydantic Models (Schemas)
├── Database Connection
├── Authentication Logic
├── Route Handlers
│   ├── @app.get()
│   ├── @app.post()
│   ├── @app.put()
│   ├── @app.delete()
│   └── @app.patch()
└── Error Handlers
```

### Testing

```bash
# If pytest available
pytest -v

# Or run specific test
pytest tests/test_auth.py -v
```

### Code Style

```bash
# Install linters
pip install flake8 black pylint

# Format code
black main.py

# Lint
flake8 main.py
pylint main.py
```

---

## 🔑 Environment Variables

| Variable                      | Required | Default | Mô Tả                     |
| ----------------------------- | -------- | ------- | ------------------------- |
| `DATABASE_URL`                | ✅       | -       | MongoDB connection string |
| `SECRET_KEY`                  | ✅       | -       | JWT secret key            |
| `ALGORITHM`                   | ❌       | HS256   | JWT algorithm             |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | ❌       | 30      | Token expiry time         |
| `GOOGLE_API_KEY`              | ✅       | -       | Google Generative AI key  |
| `DEBUG`                       | ❌       | False   | Debug mode                |

---

## 📝 Error Handling

### Standard Response Format

**Success**:

```json
{
  "success": true,
  "data": {},
  "message": "Operation successful"
}
```

**Error**:

```json
{
  "success": false,
  "error": "ERROR_CODE",
  "message": "Error description"
}
```

### Common Error Codes

- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `422`: Validation Error
- `500`: Server Error

---

## 🚀 Deployment

### Using Gunicorn

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 main:app
```

### Using Docker

```bash
# Build
docker build -t ky_nang_song_backend .

# Run
docker run -p 8000:8000 \
  -e DATABASE_URL="mongodb://mongo:27017/ky_nang_song" \
  -e SECRET_KEY="your_secret_key" \
  ky_nang_song_backend
```

### Environment Setup for Production

- Set `DEBUG=False`
- Use strong `SECRET_KEY`
- Enable HTTPS
- Configure CORS properly
- Use environment variables for sensitive data

---

## 🐛 Troubleshooting

### MongoDB Connection Error

```bash
# Check if MongoDB is running
# Local: mongod should be running
# Cloud: Check connection string and credentials
```

### Import Errors

```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

### Port Already in Use

```bash
# Change port
uvicorn main:app --port 8001
```

---

## 📚 Tài Liệu Tham Khảo

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [JWT Authentication](https://tools.ietf.org/html/rfc7519)
- [Google Generative AI](https://ai.google.dev/)

---

## 🤝 Đóng Góp

Vui lòng đọc guidelines ở repository chính.

---

## 📄 License

MIT License - See main repository

---

**API Backend for Kỹ Năng Sống 4.0**
Last Updated: May 2026
