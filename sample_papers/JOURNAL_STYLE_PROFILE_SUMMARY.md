# Báo Cáo Tóm Lược DNA Văn Phong Tạp Chí Khoa Học
## (Scientific Journal Style Profile Executive Summary)

> **Dữ liệu đối chuẩn:** Tổng hợp tự động từ **300 bài báo toàn văn** (2021 – 2024), **3.280 câu văn học thuật**, **85.200 tokens**.  
> **Nguồn lưu trữ:** Object Storage MinIO Local (`jsm-articles/raw/...`) & Cơ sở dữ liệu PostgreSQL.  
> **Xử lý bóc tách:** GROBID TEI-XML Parser (Member 2) & NLP Feature Extractor + AI Move Classifier (Member 3).

---

## 1. Thông Tin Tạp Chí Đối Chuẩn (Target Journal)
- **Tên đầy đủ:** IEEE Transactions on Software Engineering (IEEE TSE)
- **Nhà xuất bản:** IEEE Computer Society
- **Chỉ số uy tín:** Q1 • Impact Factor: **6.5**
- **ISSN:** 0098-5589
- **Lĩnh vực trọng tâm:** Software Engineering, Empirical Evaluation, Static/Dynamic Analysis, Code Smells, Architecture Debt.

---

## 2. Các Chỉ Số Cốt Lõi Về Văn Phong (Style Metrics)

### 2.1. Phân Vị Độ Dài Câu (Sentence Length Distribution)
*Tạp chí IEEE TSE có xu hướng viết câu gãy gọn, tập trung luận điểm, tránh câu ghép quá 3 mệnh đề.*
- **P10 (Câu ngắn / nhấn mạnh):** **14.2 từ**
- **P25 (Câu trung bình ngắn):** **19.0 từ**
- **P50 (Trung vị - Chuẩn vàng IEEE TSE):** **25.2 từ/câu** *(Chuẩn mực lý tưởng khi viết)*
- **P75 (Câu giải thích phương pháp):** **32.5 từ**
- **P90 (Câu phức ghép tối đa):** **41.0 từ** *(Nếu câu vượt quá 45 từ, hệ thống sẽ cảnh báo quá dài)*

### 2.2. Giọng Văn & Ngôi Xưng (Voice & Pronoun Stance)
- **Thể chủ động (Active Voice):** **74.5%** *(Khuyến khích mạnh - hành văn chủ động, rõ chủ thể)*
- **Thể bị động (Passive Voice):** **25.5%** *(Chỉ dùng nhiều ở phần Methodology)*
- **Đại từ ngôi xưng thứ nhất (*We / Our*):** **24.2%** *(Được chấp nhận và sử dụng tự nhiên trong việc tuyên bố đóng góp và mục tiêu nghiên cứu)*

### 2.3. Thước Đo Lập Luận Học Thuật (Hyland 2005 Academic Stance)
*Tần suất xuất hiện trên mỗi 1.000 từ (per 1,000 words):*
- **Hedge Markers (Thận trọng / Giảm nhẹ):** **16.8 từ/1k từ** *(e.g., suggest, indicate, potential, might, likely)*
- **Booster Markers (Khẳng định / Tự tin):** **7.2 từ/1k từ** *(e.g., demonstrate, definitely, clearly, significant)*
- **Reporting Verbs (Dẫn luận / Trích dẫn):** **12.4 từ/1k từ** *(e.g., argue, evaluate, propose, observe)*

---

## 3. Phân Bố Cấu Trúc Diễn Ngôn IMRaD & 11 Nhãn AI (Rhetorical Moves)

| Rhetorical Move (Diễn Ngôn) | Tỷ lệ xuất hiện | Section xuất hiện nhiều nhất | Ý nghĩa trong bài báo |
| :--- | :---: | :---: | :--- |
| **METHOD** (Phương pháp thực nghiệm) | **28.7%** | Methods & Evaluation | Mô tả thuật toán, dataset, metrics đo lường |
| **RESULT** (Kết quả & Phát hiện) | **23.8%** | Results | Báo cáo số liệu, p-value, bảng đối sánh |
| **BACKGROUND** (Bối cảnh học thuật) | **11.6%** | Introduction | Tổng quan nền tảng lý thuyết hiện hữu |
| **CONTRIBUTION** (Đóng góp mới) | **10.7%** | Intro / Conclusion | Tuyên bố điểm đột phá của nghiên cứu |
| **GAP** (Lỗ hổng nghiên cứu) | **8.5%** | Introduction | Chỉ ra điểm yếu/khoảng trống của các nghiên cứu trước |
| **PURPOSE** (Mục đích nghiên cứu) | **7.3%** | Introduction | Xác định câu hỏi nghiên cứu (RQ1, RQ2...) |
| **LIMITATION** (Giới hạn & Thách thức) | **5.2%** | Discussion / Threats | Phân tích Threats to Validity (nội tại, ngoại vi) |
| **CONCLUSION** (Kết luận & Hướng tới) | **4.2%** | Conclusion | Tóm tắt tác động và hướng nghiên cứu tương lai |

---

## 4. Cụm Từ Vựng Học Thuật Đặc Trưng (Lexical Bundles - N-grams)
*Những mẫu cụm từ 3-4 từ có tần suất lặp lại cao nhất trong các bài báo IEEE TSE:*
1. **`in this paper we`** (412 lần xuất hiện - Dùng cho nhãn *CONTRIBUTION*)
2. **`results indicate that`** (320 lần xuất hiện - Dùng cho nhãn *RESULT*)
3. **`threats to validity`** (280 lần xuất hiện - Dùng cho nhãn *LIMITATION*)
4. **`our empirical evaluation`** (245 lần xuất hiện - Dùng cho nhãn *METHOD*)
5. **`the state of the art`** (198 lần xuất hiện - Dùng cho nhãn *BACKGROUND / GAP*)

---

## 5. Từ Khóa Trọng Yếu Theo Phép Thử Log-Likelihood (Keyness Words)
*Các từ khóa có tần suất đột biến so với kho ngữ liệu tiếng Anh thông thường (p < 0.0001):*
- **`refactoring`** (LL: 98.4 • Tỷ lệ so chuẩn: 3.2x)
- **`empirical`** (LL: 84.2 • Tỷ lệ so chuẩn: 2.9x)
- **`smell`** (LL: 76.5 • Tỷ lệ so chuẩn: 3.5x)
- **`maintainability`** (LL: 62.1 • Tỷ lệ so chuẩn: 2.4x)

---

## 6. Hướng Dẫn Dành Cho Tác Giả / Sinh Viên Nộp Bài Vào IEEE TSE

1. **Về độ dài câu:** Duy trì trung vị khoảng **23 – 28 từ/câu**. Cắt nhỏ các câu dài hơn 42 từ thành 2 câu đơn có liên từ rõ ràng (*Furthermore, Consequently, However*).
2. **Về giọng văn:** Hãy viết **chủ động** (*"We propose...", "We evaluated..."* thay vì lạm dụng bị động *"It was evaluated by us..."*). Giữ tỷ lệ chủ động trên 70%.
3. **Về cấu trúc Abstract & Intro:** Phải có đầy đủ chuỗi diễn ngôn 4 bước:  
   `BACKGROUND` ➔ `GAP` ➔ `PURPOSE` ➔ `CONTRIBUTION`.
4. **Về phần Discussion:** Bắt buộc có tiểu mục riêng phân tích **Threats to Validity** (Construct, Internal, External validity) với độ thận trọng cao (Hedge markers như *suggest, may, could*).
