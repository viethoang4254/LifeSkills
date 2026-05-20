import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timezone

MONGO_URL = "mongodb://localhost:27017"
DB_NAME = "ky_nang_song"

news_data = [
    {
        "title": "Cẩm nang an toàn: Kỹ năng sinh tồn khi xảy ra hỏa hoạn",
        "summary": "10 bước cơ bản giúp bạn và gia đình an toàn khi sống ở chung cư và đối mặt với sự cố cháy nổ.",
        "content": "Hỏa hoạn là một trong những tai nạn nguy hiểm nhất.\n\nĐê bảo vệ bản thân và gia đình:\n1. Bình tĩnh và giữ thấp người (khí độc bay ở trên).\n2. Dùng khăn ướt che mũi miệng.\n3. Tuyệt đối không sử dụng thang máy.\n4. Tìm lối ra lối thoát hiểm gần nhất.\n\nTrong trường hợp bị mắc kẹt, hãy chặn khe cửa bằng đồ ướt và ra ban công gọi cứu hộ 114.",
        "image_url": "https://images.unsplash.com/photo-1549468057-5ce754b4fa66?q=80&w=600&auto=format&fit=crop",
        "author": "Đội PCCC",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Nghệ thuật giao tiếp: Cách nói chuyện tự tin trước đám đông",
        "summary": "Mọi người đều sợ nói trước đám đông, nhưng đây là kỹ năng có thể luyện tập.",
        "content": "Sợ hãi khi thuyết trình là bản năng tự nhiên. Nhưng bạn có thể vượt qua nó bằng cách: \n- Chuẩn bị thật kỹ nội dung và thiết kế Slide bắt mắt.\n- Luyện tập trước gương hoặc với nhóm nhỏ.\n- Hít thở sâu trước khi bắt đầu.\n- Giao tiếp bằng mắt với người nghe.\n- Sử dụng ngôn ngữ cơ thể thoải mái, tự tin.",
        "image_url": "https://images.unsplash.com/photo-1475721027785-f74eccf877e2?q=80&w=600&auto=format&fit=crop",
        "author": "Master Communication",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Quản lý tài chính cá nhân cho học sinh, sinh viên",
        "summary": "Cách tiết kiệm tiền hiệu quả và không bị viêm màng túi vào cuối tháng.",
        "content": "Sinh viên thường xuyên gặp cảnh đầu tháng ăn nhà hàng, cuối tháng ăn mì gói.\n\nHãy lập ngân sách theo quy tắc 50-30-20:\n- 50% nhu cầu thiết yếu (nhà ở, ăn uống, đi lại)\n- 30% sở thích cá nhân\n- 20% rèn luyện và tiết kiệm dự phòng.\n\nHãy ưu tiên ghi chép các khoản chi tiêu mỗi cuối ngày.",
        "image_url": "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?q=80&w=600&auto=format&fit=crop",
        "author": "Admin Tài chính",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Tư duy tích cực: Cách thay đổi suy nghĩ tiêu cực thành động lực",
        "summary": "Não bộ chúng ta có xu hướng tập trung vào những điều tiêu cực. Hãy học cách luyện thói quen nghĩ tích cực.",
        "content": "Khi gặp thất bại, thay vì suy nghĩ 'Tôi là kẻ thất bại', hãy nghĩ 'Tôi chưa thành công và sẽ cố gắng lần sau'.\n\nBiện pháp thực hành:\n1. Ghi chép 3 điều tích cực mỗi ngày trước khi ngủ\n2. Tránh các cuộc trò chuyện lăng mang, tiêu cực\n3. Đọc/nghe những câu chuyện inspiration hàng ngày\n4. Khi có suy nghĩ tiêu cực, hãy ngay lập tức thay thế bằng một suy nghĩ tích cực",
        "image_url": "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=600&auto=format&fit=crop",
        "author": "Chuyên gia Tâm lý",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Quản lý căng thẳng: 5 cách giúp bạn thư giãn nhanh chóng",
        "summary": "Căng thẳng ở nơi làm việc là điều chắc chắn xảy ra. Biết cách xử lý sẽ giúp bạn hiệu quả hơn.",
        "content": "Kỹ thuật 5-4-3-2-1: Hít thở sâu và liệt kê\n- 5 điều bạn nhìn thấy\n- 4 điều bạn cảm nhận\n- 3 điều bạn nghe\n- 2 điều bạn ngửi\n- 1 điều bạn nếm\n\nCách khác: thể dục nhẹ, thiền, viết nhật ký, hay đơn giản là uống một tách trà ấm trong vài phút.",
        "image_url": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600&auto=format&fit=crop",
        "author": "Mindfulness Coach",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Kỹ năng lắng nghe: Bí quyết để xây dựng mối quan hệ tốt",
        "summary": "Ít ai biết rằng lắng nghe là một kỹ năng quan trọng hơn nói. Tìm hiểu cách lắng nghe hiệu quả.",
        "content": "Lắng nghe không phải là chỉ nghe bằng tai, mà là nghe bằng trái tim.\n\nCác nguyên tắc lắng nghe tốt:\n1. Tắt điện thoại, xóa mọi phiền nhiễu\n2. Ghi nhận cảm xúc của người nói\n3. Không vội vàng có ý kiến hay phản bác\n4. Đặt câu hỏi thêm để hiểu rõ hơn\n5. Nhật ký lại những điểm quan trọng\n\nMối quan hệ tốt bắt đầu từ việc lắng nghe thực sự.",
        "image_url": "https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=600&auto=format&fit=crop",
        "author": "Relationship Expert",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Quản lý thời gian hiệu quả: Từ lộn xộn tới có kế hoạch",
        "summary": "Bạn sẽ ngạc nhiên khi biết rằng ai cũng có 24 giờ một ngày. Chỉ là cách sử dụng thôi.",
        "content": "Kỹ thuật Khối thời gian (Time Blocking):\n- Chia ngày thành các khối: sáng (4h), trưa (4h), chiều (4h), tối (4h)\n- Mỗi khối được gán một loại công việc cụ thể\n- Ưu tiên công việc quan trọng vào lúc năng suất cao\n- Không đa nhiệm, tập trung 100% vào một việc\n\nĐây là cách để từ 'bận rộn vô ích' chuyển sang 'bận rộn hiệu quả'.",
        "image_url": "https://images.unsplash.com/photo-1633356122544-f134324ef6db?q=80&w=600&auto=format&fit=crop",
        "author": "Productivity Hacker",
        "created_at": datetime.now(timezone.utc).isoformat()
    }
]

fun_data = [
    {
        "title": "Mẹo vặt: Mở nắp hộp thủy tinh siêu chặt cực nhanh",
        "type": "tip",
        "media_url": "https://images.unsplash.com/photo-1627485937980-221c88ce04ea?q=80&w=600&auto=format&fit=crop",
        "content": "Nếu lọ mứt nhà bạn vặn quá chặt, hãy chúi ngược và nhúng nắp hộp ngập nước nóng 30 giây để giãn nở. Hoặc đơn giản là dùng một dây thun nịt cuốn quanh viền nắp để bám tay hơn 10 độ.",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Khám phá: Những vùng đất lạnh giá nhất thế giới",
        "type": "video",
        "media_url": "https://images.unsplash.com/photo-1478719059408-592965723cbc?q=80&w=600&auto=format&fit=crop",
        "content": "Khám phá những vùng thuộc Oymyakon, nơi nhiệt độ có thể xuống -71 độ C khiến mọi thứ lập tức đông cứng.",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Cảm hứng mỗi ngày",
        "type": "tip",
        "media_url": "https://images.unsplash.com/photo-1499750310107-5fef28a66643?q=80&w=600&auto=format&fit=crop",
        "content": "\"Người thành công không bao giờ từ bỏ, còn người từ bỏ không bao giờ thành công.\" Cuộc sống là một cuộc chạy Marathon, hãy bền bỉ rèn luyện mỗi ngày.",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Mẹo làm sạch màn hình điện thoại đúng cách",
        "type": "tip",
        "media_url": "https://images.unsplash.com/photo-1511707267537-b85faf00021e?q=80&w=600&auto=format&fit=crop",
        "content": "Dùng nước cất trộn với giấm trắng theo tỷ lệ 1:1, thấm vào khăn mềm rồi lau màn hình. Tuyệt đối đừng dùng nước vòi khiến thiết bị bị ẩm.",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Cách hack: Ngủ sâu hơn trong 2 phút",
        "type": "tip",
        "media_url": "https://images.unsplash.com/photo-1541123603104-852e8ae4a86a?q=80&w=600&auto=format&fit=crop",
        "content": "Kỹ thuật 4-7-8: Hít vào trong 4 giây, giữ hơi trong 7 giây, thở ra trong 8 giây. Lặp lại 4 lần, bạn sẽ nhanh chóng rơi vào giấc ngủ sâu.",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Factpack: Não người thay đổi như thế nào khi học?",
        "type": "video",
        "media_url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=600&auto=format&fit=crop",
        "content": "Mỗi khi bạn học cái gì đó mới, não bộ tạo ra những đường nối thần kinh mới. Đó là lý do tại sao luyện tập đều đặn làm cho bạn trở nên tốt hơn.",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Miếng tin vui: Cười giúp bạn khỏe hơn",
        "type": "tip",
        "media_url": "https://images.unsplash.com/photo-1517457373614-b7152f800fd1?q=80&w=600&auto=format&fit=crop",
        "content": "Cười giúp giảm stress hormone cortisol và tăng endorphin (hormone hạnh phúc). Cười một lúc có tác dụng tương tự như tập thể dục 10 phút!",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Khám phá: 10 thói quen của những người thành công",
        "type": "video",
        "media_url": "https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=600&auto=format&fit=crop",
        "content": "Dậy sớm, tập thể dục, ghi chép mục tiêu hàng ngày... Những người thành công đều tuân theo các thói quen cơ bản này.",
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Mẹo tinh tế: Cách tiết kiệm pin điện thoại đến 50%",
        "type": "tip",
        "media_url": "https://images.unsplash.com/photo-1556656793-08538906a9f8?q=80&w=600&auto=format&fit=crop",
        "content": "Tắt định vị, giảm độ sáng màn hình, tắt các ứng dụng chạy nền, và sử dụng chế độ tối. Những bước nhỏ này sẽ tiết kiệm đáng kể pin của bạn.",
        "created_at": datetime.now(timezone.utc).isoformat()
    }
]

skills_data = [
    {
        "title": "Kỹ năng sơ cứu cầm máu khẩn cấp",
        "category": "Sức khỏe & Y tế",
        "description": "Biết cách cầm máu và sát trùng vết thương hở để tránh nhiễm trùng nghiêm trọng trước khi được cấp cứu.",
        "image_url": "https://tse4.mm.bing.net/th/id/OIP.E-nKXVsLvSmpLe-pp-njGgHaE6?pid=Api&P=0&h=180",
        "content": "Việc cần làm ngay khi gặp người bị thương:\n1. Rửa tay sát khuẩn nhanh nếu có thể.\n2. Dùng vải/gạc thật sạch ép chặt khu vực vết thương.\n3. Nâng cao vùng bị thương (như tay, chân) cao hơn tim để giảm dòng máu.\n4. Đưa nạn nhân đến trạm y tế gần nhất.",
        "duration_minutes": 10,
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Kỹ năng thoát hiểm võ thuật cơ bản",
        "category": "Sinh tồn",
        "description": "Bỏ túi những mẹo thoát thân khi bị nắm tóc, vòng cổ hoặc khống chế bất ngờ.",
        "image_url": "https://i.ytimg.com/vi/wjq9IcaapM8/maxresdefault.jpg",
        "content": "Nguyên tắc VÀNG: Bỏ chạy luôn là hạ sách nhưng an toàn nhất.\n- Nếu bị nắm cổ tay: Hãy giật mạnh xoay về hướng khe hở giữa ngón cái và ngón trỏ của kẻ xấu.\n- Nếu bị ôm từ phía sau: Dậm mạnh gót chân bạn vào mu bàn chân của hắn, sau đó húc đầu mạnh về sau.\n- Hô hoán \"CỨU CHÁY!\" thay vì \"Cứu tôi\" để thu hút đông người hơn.",
        "duration_minutes": 15,
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Bảo mật tài khoản ngân hàng & Mạng",
        "category": "An toàn Số",
        "description": "Kỹ năng nhận diện lừa đảo SMS và cách thiết lập bức tường phòng thủ ảo.",
        "image_url": "https://viettelsoftware.com/images/bank-5.jpg",
        "content": "- Không nhận link lạ từ bất kể người thân nhắn qua Facebook (họ có thể bị hack).\n- Bật tính năng Xác thực 2 bước (2 Fac Auth) cho mọi nền tảng.\n- Không bao giờ đặt mật khẩu chung cho Ngân Hàng và Mạng xã hội.",
        "duration_minutes": 8,
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Giao tiếp hiệu quả: Trở thành người nói chuyện giỏi",
        "category": "Kỹ năng Giao tiếp",
        "description": "Học cách diễn đạt ý tưởng rõ ràng, mạch lạc và thuyết phục người khác.",
        "image_url": "https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=600&auto=format&fit=crop",
        "content": "Bí quyết nói chuyện giỏi:\n1. Chuẩn bị nội dung trước khi nói\n2. Nói từ từ, rõ ràng và không vội vàng\n3. Sử dụng ví dụ cụ thể, dễ hiểu\n4. Chú ý đến phản ứng của người nghe\n5. Chỉ nói những điều bạn chắc chắn\n6. Sử dụng ngôn ngữ cơ thể tự tin\n7. Lắng nghe và không cắt ngang người khác",
        "duration_minutes": 12,
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Quản lý tài chính: Làm chủ tiền bạc của bạn",
        "category": "Tài chính & Kinh tế",
        "description": "Cách lập kế hoạch chi tiêu, tiết kiệm và đầu tư khôn ngoan.",
        "image_url": "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?q=80&w=600&auto=format&fit=crop",
        "content": "5 bước quản lý tài chính:\n1. Ghi chép tất cả khoản chi tiêu trong 1 tháng\n2. Phân loại: nhu cầu (50%), muốn (30%), tiết kiệm (20%)\n3. Lập sẵn ngân sách hàng tháng\n4. Xây dựng quỹ khẩn cấp 3-6 tháng\n5. Bắt đầu đầu tư từ khoản tiết kiệm\n\nĐiều quan trọng: Không bao giờ chi tiêu hơn mức thu nhập.",
        "duration_minutes": 14,
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Kỹ năng giải quyết xung đột",
        "category": "Kỹ năng xã hội",
        "description": "Cách xử lý mâu thuẫn một cách xây dựng mà không làm mất mối quan hệ.",
        "image_url": "https://www.pace.edu.vn/uploads/news/2023/10/4-cach-cai-thien-ky-nang-giai-quyet-xung-dot.jpg",
        "content": "5 bước để giải quyết xung đột:\n1. Bình tĩnh lại, đợi 24 tiếng nếu có thể\n2. Nghe đủ quan điểm của bên kia\n3. Diễn tả cảm xúc của bạn mà không tấn công\n4. Tìm điểm chung, mục tiêu chung\n5. Thống nhất giải pháp có lợi cho cả hai bên\n\nNhớ: Yêu người nhưng đừng yêu mâu thuẫn.",
        "duration_minutes": 11,
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Quản lý thời gian: Làm được nhiều hơn trong ngày",
        "category": "Năng suất & Hiệu quả",
        "description": "Học sử dụng thời gian hiệu quả nhất để đạt được mục tiêu của bạn.",
        "image_url": "https://static.vinwonders.com/production/ky-nang-quan-ly-thoi-gian-1-1536x1094.jpg",
        "content": "3 phương pháp quản lý thời gian:\n\n1. Kỹ thuật Pomodoro: 25 phút làm việc + 5 phút nghỉ\n2. Phương pháp ABC: A (quan trọng), B (trung bình), C (ít quan trọng)\n3. Time Blocking: Chia ngày thành các khối thời gian cụ thể\n\nTip vàng: Làm việc quan trọng nhất vào lúc năng suất cao nhất (thường sáng sớm)",
        "duration_minutes": 13,
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Lập mục tiêu SMART: Từ giấc mơ đến hiện thực",
        "category": "Phát triển bản thân",
        "description": "Cách đặt mục tiêu rõ ràng, có thể đo lường được để đạt được thành công.",
        "image_url": "https://vinacontrolce.vn/wp-content/uploads/2023/06/mo-hinh-smart-2-1024x584.jpg",
        "content": "Mục tiêu SMART phải có:\n- S (Specific): Cụ thể, rõ ràng\n- M (Measurable): Có thể đo lường được\n- A (Achievable): Có thể đạt được\n- R (Relevant): Phù hợp với bạn\n- T (Time-bound): Có thời hạn rõ ràng\n\nVí dụ:\nSai: 'Tôi muốn giàu hơn'\nĐúng: 'Tôi muốn tiết kiệm 10 triệu đồng trong 1 năm bằng cách tiết kiệm 800k/tháng'",
        "duration_minutes": 9,
        "created_at": datetime.now(timezone.utc).isoformat()
    },
    {
        "title": "Kỹ năng thuyết trình: Thay đổi ý kiến mọi người",
        "category": "Lãnh đạo & Ảnh hưởng",
        "description": "Từ sợ hãi đến tự tin khi thuyết trình trước đám đông.",
        "image_url": "https://maisonoffice.vn/wp-content/uploads/2023/11/1-bi-quyet-ren-luyen-ky-nang-thuyet-trinh-hieu-qua.jpg",
        "content": "Công thức thuyết trình 4 phần:\n1. Hook (2 phút): Gây chú ý bằng câu hỏi hoặc câu chuyện thú vị\n2. Problem (3 phút): Nêu vấn đề rõ ràng\n3. Solution (5 phút): Trình bày giải pháp\n4. Call to Action (1 phút): Kêu gọi hành động\n\nTip: Luyện tập với gương hoặc nhóm nhỏ 3-5 lần trước ngày thuyết trình.",
        "duration_minutes": 16,
        "created_at": datetime.now(timezone.utc).isoformat()
    }
]

posts_data = [
    {
        "user_id": "global_admin_id",
        "user_name": "Tuấn Anh (Admin)",
        "content": "Chào mừng các bạn đến với Cộng đồng Kỹ năng sống 4.0! Mọi người hãy thoải mái chia sẻ trải nghiệm, bài học hoặc đặt câu hỏi về các kỹ năng ở đây nhé. 😉",
        "topic": "Chung",
        "likes": ["user_1", "user_2"],
        "likes_count": 2,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": True,
    },
    {
        "user_id": "user_id_123",
        "user_name": "Minh Nhật",
        "content": "Hôm nay mới đọc mẹo về quản lý tài chính sinh viên. Mọi người có app nào track chi tiêu dễ dùng và hoàn toàn miễn phí không gợi ý cho mình với?",
        "topic": "Hỏi đáp",
        "likes": [],
        "likes_count": 0,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    },
    {
        "user_id": "user_id_456",
        "user_name": "Hải Yến",
        "content": "Vừa học xong kỹ năng sơ cứu! Thật sự rất bổ ích các bạn ạ. Chắc chắn tháng tới sau khi nhận lương mình sẽ đầu tư ngay 1 bộ kit sơ cứu ở nhà.",
        "topic": "Chia sẻ",
        "likes": ["global_admin_id", "user_id_123"],
        "likes_count": 2,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    },
    {
        "user_id": "user_id_789",
        "user_name": "Trần Quân",
        "content": "Có ai đã thử kỹ thuật Pomodoro chưa? Mình used nó từ 2 tuần trước và productivity tăng gấp đôi! Lúc đầu khó tập trung nhưng giờ thì bình thường rồi.",
        "topic": "Chia sẻ",
        "likes": ["user_id_123", "user_id_456"],
        "likes_count": 2,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    },
    {
        "user_id": "user_id_234",
        "user_name": "Lan Anh",
        "content": "Mình vừa mới học kỹ năng giao tiếp hiệu quả. Nghe có vẻ đơn giản nhưng trên thực tế áp dụng vào công việc thì cần rất nhiều thực hành. Có hint nào từ mọi người không?",
        "topic": "Hỏi đáp",
        "likes": ["user_id_789"],
        "likes_count": 1,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    },
    {
        "user_id": "user_id_567",
        "user_name": "Phạm Hùng",
        "content": "Tip quản lý tài chính siêu hay! Mình bắt đầu áp dụng quy tắc 50-30-20 từ hôm nay. Sẽ update lại sau 1 tháng để cho các bạn biết kết quả 💪",
        "topic": "Chia sẻ",
        "likes": ["user_id_123", "user_id_456", "user_id_789"],
        "likes_count": 3,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    },
    {
        "user_id": "user_id_890",
        "user_name": "Ngô Thảo",
        "content": "Bắt đầu lập mục tiêu SMART từ hôm nay. Sau khi lập xong mình cảm thấy động lực tăng vọt. Cảm ơn platform này đã tạo động lực cho mình!",
        "topic": "Chia sẻ",
        "likes": ["global_admin_id", "user_id_567"],
        "likes_count": 2,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    },
    {
        "user_id": "user_id_345",
        "user_name": "Võ Minh",
        "content": "Ai đó giúp mình với! Mình cần thiết kế một bài thuyết trình cho buổi hội thảo công ty. Mẹo nào để bắt đầu hiệu quả và khiến người nghe quan tâm?",
        "topic": "Hỏi đáp",
        "likes": ["user_id_234"],
        "likes_count": 1,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    },
    {
        "user_id": "user_id_678",
        "user_name": "Lê Hương",
        "content": "Nghe bảo 'Người thành công đều có thói quen dậy sớm'. Tôi cũng cố gắng thức dậy lúc 5h sáng nhưng lại ngủ tiếp... Có ai có bí quyết để duy trì thói quen này không?",
        "topic": "Hỏi đáp",
        "likes": ["user_id_890"],
        "likes_count": 1,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    },
    {
        "user_id": "user_id_901",
        "user_name": "Đặng Tân",
        "content": "Kỹ năng giải quyết xung đột thực sự bổ ích! Mình vừa áp dụng nó với một mâu thuẫn ở nhà và cảm giác tuyệt vời khi mọi thứ được giải quyết một cách bình tĩnh.",
        "topic": "Chia sẻ",
        "likes": ["user_id_123", "user_id_234", "user_id_567"],
        "likes_count": 3,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    },
    {
        "user_id": "user_id_012",
        "user_name": "Bùi Linh",
        "content": "Mình là lần đầu tiên sử dụng ứng dụng này. Thực sự ấn tượng với cách thiết kế và nội dung, rất dễ hiểu và thực tế. Khuyến cáo cao cho ai muốn phát triển bản thân!",
        "topic": "Chung",
        "likes": ["global_admin_id", "user_id_456", "user_id_789"],
        "likes_count": 3,
        "comments_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "is_hidden": False,
        "is_pinned": False,
    }
]

async def seed():
    client = AsyncIOMotorClient(MONGO_URL)
    db = client[DB_NAME]
    
    # Xóa dữ liệu cũ
    await db["news"].delete_many({})
    await db["fun"].delete_many({})
    await db["skills"].delete_many({})
    await db["posts"].delete_many({})
    
    # Thêm dữ liệu mới
    await db["news"].insert_many(news_data)
    await db["fun"].insert_many(fun_data)
    await db["skills"].insert_many(skills_data)
    await db["posts"].insert_many(posts_data)
    print("✅ Đã bơm Mock Data thành công cho Trang Tin Tức, Vui học, Kỹ năng và Cộng đồng!")
    client.close()

if __name__ == "__main__":
    asyncio.run(seed())
