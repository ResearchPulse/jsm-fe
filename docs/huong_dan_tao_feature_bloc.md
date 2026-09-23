# Hướng dẫn Xây dựng Feature theo Chuẩn Bloc/Cubit (Clean Architecture)

Tài liệu này định nghĩa cấu trúc và quy trình chuẩn để tạo ra một tính năng (feature) mới trong dự án `jsm_fe`. Việc tuân thủ cấu trúc này giúp mã nguồn dễ bảo trì, dễ kiểm thử (test), và có khả năng mở rộng cao.

## 1. Tổng quan Kiến trúc

Dự án áp dụng mô hình **Feature-Driven Architecture** kết hợp với **Clean Architecture**. Mỗi feature (tính năng) sẽ là một thư mục độc lập nằm trong `lib/features/`, bao gồm 3 tầng (layer) chính:

```text
features/[tên_feature]/
├── data/               # Tầng tương tác với dữ liệu (API, Local DB)
├── domain/             # Tầng chứa logic nghiệp vụ cốt lõi (Không phụ thuộc Framework)
└── presentation/       # Tầng giao diện người dùng (UI) và Quản lý trạng thái (Bloc/Cubit)
```

---

## 2. Chi tiết Từng Tầng (Layers)

### 2.1 Tầng Domain (Nghiệp vụ Cốt lõi)
Tầng này là trung tâm của feature, **không được phép import bất kỳ thư viện UI nào (ví dụ: `flutter/material.dart`) hay thư viện Data (như Dio, HTTP)**.

- **`entities/`**: Định nghĩa cấu trúc dữ liệu thuần túy của ứng dụng (Model không chứa logic parse JSON). Nên dùng `Equatable` để so sánh object.
- **`repositories/`**: Chứa các Interface/Abstract class. Định nghĩa các hàm (hành động) có thể thực hiện (vd: `getJournals()`, `login()`).
- **`usecases/`** (Tuỳ chọn nhưng khuyến khích): Mỗi class đại diện cho một tác vụ nghiệp vụ duy nhất (Ví dụ: `GetFeaturedJournalsUseCase`).

### 2.2 Tầng Data (Quản lý Dữ liệu)
Tầng này chịu trách nhiệm implement các interface đã khai báo ở tầng Domain.

- **`models/`**: Kế thừa từ `Entity` bên tầng Domain nhưng có thêm các logic như `fromJson`, `toJson` để giao tiếp với API hoặc Database.
- **`datasources/`**: Nơi trực tiếp gọi API (Remote DataSource) hoặc truy xuất bộ nhớ cục bộ (Local DataSource). Ném ra `Exception` nếu có lỗi.
- **`repositories/`**: Implement các Interface ở tầng Domain. Gọi dữ liệu từ `datasources`, bắt `Exception` và chuyển đổi (map) thành các `Failure` (vd: `ServerFailure`) để trả về cho tầng Presentation.

### 2.3 Tầng Presentation (Giao diện & Quản lý Trạng thái)
Nơi duy nhất giao tiếp với người dùng và phản hồi lại tương tác.

- **`cubit/` hoặc `bloc/`**: Quản lý State của màn hình. Nhận event từ UI, gọi `Usecase` hoặc `Repository` ở tầng Domain, sau đó `emit` ra các State (Loading, Loaded, Error) để UI tự cập nhật.
- **`pages/` hoặc `screens/`**: Chứa các file màn hình chính (Widget bọc toàn bộ trang).
- **`widgets/`**: Chứa các thành phần UI nhỏ lẻ, dùng riêng cho feature này (nếu UI dùng chung cho toàn app, hãy đặt ở `lib/core/widgets/`).

---

## 3. Quy trình Step-by-Step để tạo 1 Feature mới

Giả sử bạn cần tạo một feature tên là **`profile`**. Hãy làm theo các bước sau (từ trong ra ngoài):

### Bước 1: Khởi tạo Tầng Domain
1. Tạo thư mục: `lib/features/profile/domain/`
2. Tạo `entities/profile_entity.dart`: Định nghĩa class Profile với các trường như `id`, `name`, `email`.
3. Tạo `repositories/profile_repository.dart`: Định nghĩa Interface abstract class có phương thức `Future<ProfileEntity> getUserProfile();`
4. Tạo `usecases/get_user_profile_usecase.dart`: Nhận `ProfileRepository` qua constructor và thực thi logic lấy dữ liệu.

### Bước 2: Xây dựng Tầng Data
1. Tạo thư mục: `lib/features/profile/data/`
2. Tạo `models/profile_model.dart` (extends `ProfileEntity`) với hàm `factory ProfileModel.fromJson()`.
3. Tạo `datasources/profile_remote_datasource.dart`: Chứa class gọi HTTP client (như Dio) tới backend `jsm-be`.
4. Tạo `repositories/profile_repository_impl.dart`: Implement `ProfileRepository`. Ở đây bạn gọi hàm từ datasource, bắt `ServerException` và throw/return về `ServerFailure`.

### Bước 3: Tạo Tầng Presentation & Quản lý trạng thái (Cubit/Bloc)
1. Tạo thư mục: `lib/features/profile/presentation/cubit/`
2. Tạo `profile_state.dart`: Định nghĩa các state cơ bản:
   - `ProfileInitial`
   - `ProfileLoading`
   - `ProfileLoaded(this.profile)`
   - `ProfileError(this.message)`
3. Tạo `profile_cubit.dart`: Kế thừa `Cubit<ProfileState>`, tiêm `GetUserProfileUseCase` vào, thực hiện hàm fetch dữ liệu và emit state tương ứng.

### Bước 4: Viết Giao diện (Pages)
1. Tạo thư mục: `lib/features/profile/presentation/pages/`
2. Tạo `profile_page.dart` (StatelessWidget/StatefulWidget).
3. Sử dụng `BlocBuilder<ProfileCubit, ProfileState>` để render UI dựa trên các trạng thái (Loading -> show spinner, Error -> show error, Loaded -> show dữ liệu).
4. Ở widget khởi tạo màn hình (hoặc tại `AppRouter`), hãy dùng `BlocProvider` để khởi tạo `ProfileCubit` trước khi render `ProfilePage`.

---

## 4. Các Quy tắc Bắt buộc (Do's and Don'ts)

✅ **NÊN LÀM:**
- Giữ cho UI (Widgets) càng "ngu" (dumb) càng tốt, UI chỉ có nhiệm vụ hiển thị dữ liệu và gửi event.
- Bắt tất cả Exception từ Server/Network ở tầng Data và chuyển đổi chúng thành các class `Failure` nằm trong `core/errors/failures.dart`.
- Sử dụng `equatable` để các state và entity so sánh được giá trị một cách chính xác (tránh re-build UI không cần thiết).

❌ **KHÔNG ĐƯỢC LÀM:**
- Không gọi trực tiếp Data Source/API Client trong Bloc/Cubit. Phải thông qua Repository/Usecase.
- Không truyền (import) các thư viện giao diện như Material/Cupertino vào tầng Domain.
- Không xử lý Logic nghiệp vụ (if/else tính toán phức tạp) ngay bên trong UI Widget.

## 5. Tham khảo Cấu trúc
Hãy tham khảo thư mục `lib/features/home/` trong source code hiện tại để xem ví dụ hoàn chỉnh về cách luồng dữ liệu (Data flow) hoạt động.
