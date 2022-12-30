create database Qlthuctap_VuThiHoaiThu
use Qlthuctap_VuThiHoaiThu

create table sinhvien(
	masv char(10) primary key,
	hotensv nvarchar(30),
	lop nvarchar(15),
)
insert into sinhvien
values  ('SV01','Nguyễn Minh Đức','D16CNPM1'),
		('SV02','Nguyễn Văn Sang','D16CNPM3'),
		('SV03','Nguyễn Thu Huyền','D16HTTMDT1'),
		('SV04','Phan Đình Anh','D16TTNT&TGMT'),
		('SV05','Trần Bảo Ngọc','D16QT&ANM')

create table giangvien(
	magv char(10) primary key,
	hoten nvarchar(30),
	sdt nvarchar(15),
)
insert into giangvien
values  ('GV01','Nguyễn Quỳnh Anh','0912107843'),
		('GV02','Bùi Khánh Linh','0912107859'),
		('GV03','Nguyễn Khánh Tùng','0912107878'),
		('GV04','Phương Văn Cảnh','0912107845'),
		('GV05','Hoàng Thanh Tùng','0912107875')

create table huongdan(
	magv char(10) foreign key references giangvien(magv),
	masv char(10) foreign key references sinhvien(masv),
	tendt nvarchar(70),
	noithuctap nvarchar(30),
	primary key(magv, masv)
)
insert into huongdan
values ('GV05', 'SV05','Xây dựng hệ thống cảnh báo email spam','Netnam'),
		('GV04','SV02','Xây dựng hệ thống tư vấn khách hàng','FSI'),
		('GV03','SV01','Xây dựng App học TA','FPT Software'),
		('GV02','SV04','Khai phá quan điểm người dùng sản phẩmSamSung','Samsung'),
		('GV01','SV03','Xây dựng hệ thống AI hỗ trợ bán hàng online','FSI')

--2) Hãy đưa ra toàn bộ thông tin trong danh sách thực tập bao gồm: 
	--họ tên của sinh viên, lớp, tên giảng viên hướng dẫn và nơi thực tập
	select hotensv, lop, hoten, noithuctap
	from sinhvien, giangvien, huongdan
	where sinhvien.masv = huongdan.masv
	and giangvien.magv = huongdan.magv
--3) Hãy viết default cho cột Nơi thực tập là “chua co noi thuc tap” nếu nơi thực tập bỏ trống.
	create default def1
	as 'Chưa có nơi thực tập'
	exec sp_bindefault 'def1','huongdan.noithuctap'
--4) Viết thủ tục nhập vào mã sinh viên sẽ hiển thị đầy đủ tên giảng viên hướng dẫn.
	create proc hienthi @masv char(10)
	as 
		if @masv is null
		begin
			print 'hay nhap ma sinh vien'
			return 
			end
		else
			begin
			select hoten
			from giangvien, huongdan, sinhvien
			where giangvien.magv = huongdan.magv
			and sinhvien.masv = huongdan.masv
			and huongdan.masv = @masv
			end
	exec hienthi 'SV02'
--5) Hãy đưa ra thông tin: họ tên sinh viên, tên đề tài, giảng viên hướng dẫn của sinh viên đi thực tập tại FSI
	select hotensv, tendt, hoten
	from sinhvien, giangvien, huongdan
	where sinhvien.masv = huongdan.masv
	and huongdan.magv = giangvien.magv
	and noithuctap = 'FSI'
--6) Hãy viết default cho cột Nơi thực tập là “chua co noi thuc tap” nếu nơi thực tập bỏ trống.
	--GIỐNG CÂU 3
--7) Viết thủ tục nhập vào mã giảng viên sẽ hiển thị đầy đủ tên sinh viên mà giảng viên đó hướng dẫn.
	create proc hienthi2 @magv char(10)
	as
		if @magv is null
		begin 
			print 'Nhap ma giang vien'
			return 
		end
		else
			begin 
			select hotensv
			from sinhvien, giangvien, huongdan
			where sinhvien.masv = huongdan.masv
			and huongdan.magv = giangvien.magv
			and huongdan.magv = @magv
		end
	exec hienthi2 'GV03'
--8) Hãy đưa ra thông tin: họ tên sinh viên, tên đề tài, giảng viên hướng dẫn của sinh viên đi thực tập tại Netnam
	select hotensv, tendt, hoten
	from sinhvien, giangvien, huongdan
	where sinhvien.masv = huongdan.masv
	and huongdan.magv = giangvien.magv
	and noithuctap = 'Netnam'
--9) Hãy hiển thị tên, điệm thoại của giảng viên hướng dẫn sinh viên thực tập tại Samsung.
	select hoten, sdt
	from giangvien, huongdan
	where giangvien.magv = huongdan.magv
	and noithuctap = 'Samsung'
--10) Hãy đưa ra thông tin: họ tên sinh viên và giảng viên hướng dẫn có tên đề tài “Xây dựng App học TA”.
	select hotensv, hoten
	from sinhvien, giangvien, huongdan
	where sinhvien.masv = huongdan.masv
	and giangvien.magv = huongdan.magv
	and tendt = 'Xây dựng App học TA'
--11) Hãy cho biết số sinh viên của lớp D16CNPM1 đi thực tập.
	select count(*) as sosv
	from sinhvien, huongdan
	where sinhvien.masv = huongdan.masv
	and lop = 'D16CNPM1'
--12) Viết thủ tục nhập vào mã sinh viên sẽ hiển thị đầy đủ tên, điện thoại của giảng viên hướng dẫn.
	create proc hienthi3 @masv char(10)
	as
		if @masv is null
		begin 
			print 'Nhap ma sinh vien'
			return 
		end
		else
		begin
			select hoten, sdt
			from giangvien, sinhvien, huongdan
			where giangvien.magv = huongdan.magv
			and huongdan.masv = sinhvien.masv
			and huongdan.masv = @masv
		end
	exec hienthi3 'SV03' 
--13) Hãy đưa ra thông tin: họ tên sinh viên, lớp và giảng viên hướng dẫn có tên đề tài “Xây dựng Appfood”.
	select hotensv, lop, hoten
	from sinhvien, giangvien, huongdan
	where sinhvien.masv = huongdan.masv
	and huongdan.magv = giangvien.magv
	and tendt = 'Xây dựng hệ thống AI hỗ trợ bán hàng online'
--14) Hãy viết view vw_HT_SV hiển thị họ tên của sinh viên và giảng viên hướng dẫn
	create view vw_HT_SV
	as
		select hotensv, hoten
		from sinhvien, giangvien, huongdan
		where sinhvien.masv = huongdan.masv
		and giangvien.magv = huongdan.magv

	select * from vw_HT_SV
--15) Sinh viên Nguyễn Minh An, Lớp D16CNPM6 mới được bổ sung vào danh sách,hãy cập nhật lại dữ liệu cho bảng SinhVien.
	insert into sinhvien
	values ('SV06','Nguyễn Minh An','D16CNPM6')
	select * from sinhvien
--16) Hãy đưa ra họ tên các sinh viên mà giảng viên Bùi Khánh Linh hướng dẫn.
	select hotensv
	from sinhvien, giangvien, huongdan
	where sinhvien.masv = huongdan.masv
	and giangvien.magv = huongdan.magv
	and hoten = 'Bùi Khánh Linh'
--17) Sinh viên Nguyễn Thị Huyền đổi nơi thực tập sang công ty Viettel. Hãy cập nhật lại thông tin cho sinh viên này.
	update huongdan
	set noithuctap = 'Viettel'
	from sinhvien, huongdan
	where sinhvien.masv = huongdan.masv
	and hotensv = 'Nguyễn Thu Huyền'

	select huongdan.* from huongdan, sinhvien where sinhvien.masv = huongdan.masv and hotensv = 'Nguyễn Thu Huyền'
--18) Hãy viết view vw_HT_GV hiển thị họ tên của giảng viên và sinh viên giảng viên đó hướng dẫn
	--khi biết mã giảng viên là “GV02”.
	create view vw_HT_GV
	as
		select hoten, hotensv
		from sinhvien, giangvien, huongdan
		where sinhvien.masv = huongdan.masv
		and giangvien.magv = huongdan.magv
	select * from vw_HT_GV
--19) Hãy backup cơ sở dữ liệu sang ổ đĩa khác trong máy tính.
	backup database Qlthuctap_VuThiHoaiThu to disk = 'D:\bai1.bak'