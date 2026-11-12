# QLHocPhan - Quản lý giảng viên

Ứng dụng Flutter quản lý collection `Giang Vien` trong Firebase Firestore theo đúng
đề thi giữa kỳ. Mỗi document chỉ có đúng bốn trường:

```json
  {
    "Document ID": "VuaZfh9cBhgU9L5Qit4M",
    "Fullname": "Lê Văn Mẩn",
    "IDGV": "GV001",
    "Image": "\"data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/4gHYSUNDX1BST0ZJTEUAAQEAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFla \n16489 characters not shown",
    "SumClass": 10
  }
```

## Chức năng

- Đăng nhập admin bằng Firebase Authentication.
- Thêm, hiển thị, tìm kiếm, sửa và xóa giảng viên.
- Nhập hình ảnh từ thư viện trên Android/iOS; ảnh được nén và lưu vào trường `Image`.
- Hiển thị responsive trên web và thiết bị di động.

## Cài đặt và chạy

Yêu cầu Flutter stable, Android Studio nếu chạy Android, và tài khoản Firebase.

```bash
flutter pub get
flutter run -d chrome
```

Chạy trên Android:

```bash
flutter devices
flutter run -d <device-id>
```

Trong Firebase Console, bật Authentication bằng Email/Password và tạo Cloud
Firestore. Tạo một tài khoản admin để đăng nhập. Deploy rules:

```bash
firebase deploy --project giuakidnt-15fb0 --only firestore:rules
```