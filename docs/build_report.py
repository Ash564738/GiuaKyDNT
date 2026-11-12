from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

ROOT = Path(__file__).resolve().parents[1]
OUT = Path(__file__).resolve().parent
OUT.mkdir(exist_ok=True)
FONT = 'C:/Windows/Fonts/arial.ttf'
FONT_B = 'C:/Windows/Fonts/arialbd.ttf'

def font(size, bold=False):
    path = FONT_B if bold else FONT
    return ImageFont.truetype(path, size) if Path(path).exists() else ImageFont.load_default()

def mockup(path, mobile=False):
    w,h = (450,760) if mobile else (1200,720)
    im=Image.new('RGB',(w,h),'#f4f6fb'); d=ImageDraw.Draw(im)
    d.rectangle((0,0,w,72),fill='#ffffff'); d.text((30,23),'Quản lý người dùng',font=font(25,True),fill='#17223b')
    if mobile:
        d.text((25,100),'Tìm theo họ tên hoặc email',font=font(17),fill='#778198')
        d.rounded_rectangle((20,130,430,184),radius=12,fill='white',outline='#d8deeb')
        rows=[('Nguyễn An','nguyen.an@example.com'),('Trần Bình','tran.binh@example.com'),('Lê Chi','le.chi@example.com')]
        for i,(name,email) in enumerate(rows):
            y=210+i*142; d.rounded_rectangle((20,y,430,y+124),radius=14,fill='white',outline='#e2e6ef')
            d.ellipse((38,y+26,94,y+82),fill='#dce5ff'); d.text((111,y+23),name,font=font(19,True),fill='#202b43'); d.text((111,y+54),email,font=font(14),fill='#68748a'); d.text((111,y+82),'Mật khẩu: ••••••••',font=font(13),fill='#68748a')
        d.rounded_rectangle((120,680,420,735),radius=25,fill='#3157d5'); d.text((147,695),'+  Thêm người dùng',font=font(18,True),fill='white')
    else:
        d.text((42,115),'Quản lý hồ sơ và hình ảnh người dùng',font=font(18),fill='#68748a')
        d.rounded_rectangle((40,158,1158,215),radius=10,fill='white',outline='#d8deeb'); d.text((64,176),'⌕   Tìm theo họ tên hoặc email',font=font(18),fill='#778198')
        d.rounded_rectangle((880,245,1158,299),radius=24,fill='#3157d5'); d.text((910,259),'+  Thêm người dùng',font=font(17,True),fill='white')
        d.rounded_rectangle((40,320,1158,680),radius=12,fill='white',outline='#e2e6ef')
        d.rectangle((41,321,1157,376),fill='#edf1fa')
        heads=[('ẢNH',70),('HỌ TÊN',190),('EMAIL',430),('MẬT KHẨU',760),('THAO TÁC',1000)]
        for t,x in heads:d.text((x,338),t,font=font(15,True),fill='#48556e')
        rows=[('Nguyễn An','nguyen.an@example.com'),('Trần Bình','tran.binh@example.com'),('Lê Chi','le.chi@example.com')]
        for i,(name,email) in enumerate(rows):
            y=405+i*86; d.ellipse((65,y,112,y+47),fill=['#dce5ff','#f5dfd5','#d9f0e5'][i]); d.text((190,y+12),name,font=font(17,True),fill='#202b43'); d.text((430,y+12),email,font=font(16),fill='#39445b'); d.text((760,y+12),'••••••••',font=font(17),fill='#68748a'); d.text((1010,y+10),'✎     🗑',font=font(20),fill='#3157d5'); d.line((42,y+65,1157,y+65),fill='#edf0f5')
    im.save(path)

desktop=OUT/'minh_hoa_web.png'; mobile=OUT/'minh_hoa_mobile.png'
mockup(desktop); mockup(mobile,True)
doc=Document(); sec=doc.sections[0]; sec.top_margin=Inches(.72); sec.bottom_margin=Inches(.72); sec.left_margin=Inches(.82); sec.right_margin=Inches(.82)
normal=doc.styles['Normal']; normal.font.name='Arial'; normal.font.size=Pt(10.5)
for st in ['Heading 1','Heading 2']:
    doc.styles[st].font.name='Arial'; doc.styles[st].font.color.rgb=RGBColor(49,87,213)
def title(t,sub=None):
    p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER; r=p.add_run(t); r.bold=True; r.font.size=Pt(23); r.font.color.rgb=RGBColor(49,87,213)
    if sub:
        p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER; p.add_run(sub).italic=True
def para(t): doc.add_paragraph(t)
def bullets(items):
    for x in items: doc.add_paragraph(x,style='List Bullet')
def code(t):
    p=doc.add_paragraph(); p.paragraph_format.left_indent=Inches(.25); r=p.add_run(t); r.font.name='Consolas'; r.font.size=Pt(9)
title('BÁO CÁO ĐỒ ÁN GIỮA KỲ','LẬP TRÌNH ĐA NỀN TẢNG — ỨNG DỤNG QUẢN LÝ NGƯỜI DÙNG')
para('Sinh viên: ............................................................    Lớp: ....................')
para('Giảng viên: ..........................................................    Ngày báo cáo: ...............')
doc.add_heading('1. Mục tiêu và công nghệ',1)
para('Xây dựng ứng dụng quản trị người dùng có đăng nhập admin và các chức năng thêm, xem, tìm kiếm, sửa, xóa. Giao diện Flutter hỗ trợ web và thiết bị di động. Firebase Authentication xác thực admin; Cloud Firestore lưu hồ sơ; Firebase Storage lưu ảnh và trả URL ảnh.')
bullets(['Flutter / Dart: giao diện đa nền tảng responsive.','Firebase Authentication: Email/Password cho tài khoản admin.','Cloud Firestore: collection users với đúng bốn trường email, matkhau, hoten, hinhanh.','Firebase Storage: tệp ảnh; Firestore chỉ lưu URL trong trường hinhanh.'])
doc.add_heading('2. Cấu trúc cơ sở dữ liệu',1)
para('Collection: users. Mỗi document gồm đúng các trường sau; document ID do Firestore tự cấp, không phải trường nghiệp vụ.')
code('{ "email": "nguyen.an@example.com", "matkhau": "Demo@123", "hoten": "Nguyễn An", "hinhanh": "https://..." }')
para('Tệp database.json đi kèm dự án có ba bản ghi dữ liệu mẫu với cùng bốn khóa. Có thể nhập thủ công trong Firebase Console hoặc dùng dữ liệu đó để trình bày cấu trúc. Các hồ sơ demo không phải tài khoản đăng nhập Firebase.')
doc.add_heading('3. Cài đặt công cụ và thư viện',1)
para('Cài Flutter stable, Android Studio/SDK nếu chạy Android, và tạo Firebase project bằng tài khoản Google. Mở terminal tại thư mục source code:')
for c in ['flutter --version','flutter create --platforms web,android,ios .','flutter pub get','dart pub global activate flutterfire_cli','firebase login','flutterfire configure'] : code(c)
para('Trong Firebase Console: bật Authentication → Email/Password; tạo tài khoản admin; tạo Firestore Database và Storage. Đăng nhập CLI Firebase rồi áp dụng luật truy cập:')
code('firebase deploy --only firestore:rules,storage')
para('Các package ứng dụng được tải bởi flutter pub get: firebase_core, firebase_auth, cloud_firestore, firebase_storage, image_picker, uuid. FlutterFire configure thay thế cấu hình mẫu tại lib/firebase_options.dart bằng thông tin Firebase project.')
doc.add_heading('4. Chạy ứng dụng và quy trình demo',1)
code('flutter run -d chrome')
code('flutter build web')
code('flutter devices')
code('flutter run -d <device-id>')
bullets(['Đăng nhập bằng admin đã tạo trong Authentication.','Thêm hồ sơ, nhập email/mật khẩu/họ tên, chọn ảnh và lưu.','Tìm kiếm hồ sơ bằng email hoặc họ tên; mở sửa để cập nhật.','Xóa hồ sơ và xác nhận; đăng xuất admin.','Trên mobile, chạy app, chọn ảnh từ thư viện, rồi kiểm tra thông tin và ảnh trong danh sách.'])
doc.add_heading('5. Ảnh minh họa giao diện',1)
para('Hình dưới là mockup minh họa bố cục ứng dụng. Khi hoàn tất cấu hình Firebase, hãy thay/bổ sung ảnh chụp màn hình thật từ máy chạy ứng dụng và Firebase Console vào bản nộp cuối.')
doc.add_picture(str(desktop),width=Inches(6.4)); doc.paragraphs[-1].alignment=WD_ALIGN_PARAGRAPH.CENTER
p=doc.add_paragraph('Hình 1. Minh họa danh sách người dùng trên web (mockup giao diện).'); p.alignment=WD_ALIGN_PARAGRAPH.CENTER
doc.add_picture(str(mobile),width=Inches(2.8)); doc.paragraphs[-1].alignment=WD_ALIGN_PARAGRAPH.CENTER
p=doc.add_paragraph('Hình 2. Minh họa danh sách người dùng trên mobile (mockup giao diện).'); p.alignment=WD_ALIGN_PARAGRAPH.CENTER
doc.add_heading('6. Ảnh cần chụp từ môi trường chạy thật',1)
bullets(['Firebase Authentication: trang tài khoản admin (không chụp/đưa mật khẩu vào báo cáo).','Firestore Console: collection users, mở document để thể hiện đủ bốn trường.','Web Chrome: màn hình đăng nhập, danh sách, form thêm/sửa, kết quả sau khi tìm/xóa.','Điện thoại/emulator: màn hình hồ sơ có ảnh vừa chọn.','Không đưa API key nhạy cảm, mật khẩu admin hoặc token vào ảnh/video công khai.'])
doc.add_heading('7. Bảo mật và giới hạn',1)
para('Đề bài yêu cầu trường matkhau, vì vậy bản demo minh họa lưu giá trị trường này đúng định dạng. Đây là cách lưu không an toàn cho sản phẩm thật; tuyệt đối không dùng mật khẩu thật. Hệ thống thực tế phải xác thực người dùng bằng Firebase Authentication và không lưu mật khẩu dạng rõ trong Firestore. Rules mẫu yêu cầu tài khoản đã xác thực; trước triển khai thực tế cần giới hạn quyền admin theo vai trò.')
doc.add_heading('8. Bàn giao và liên kết',1)
para('Source code: thư mục dự án Flutter; dữ liệu JSON: database.json; luật Firebase: firestore.rules và storage.rules; hướng dẫn chạy: README.md.')
para('GitHub source: [DÁN LINK REPOSITORY SAU KHI PUSH]')
para('Video demo: [DÁN LINK VIDEO SAU KHI QUAY VÀ ĐĂNG TẢI]')
para('Để tạo link, tạo repository GitHub và push source; quay demo cá nhân, tải lên Drive/YouTube ở chế độ được giảng viên truy cập, sau đó thay hai dòng placeholder trên.')
doc.save(OUT/'BAO_CAO.docx')
