create database Quanlynhanvien_VuThiHoaiThu
use Quanlynhanvien_VuThiHoaiThu

--Chucvu(macv, tencv, hesopc)
create table chucvu(
	macv char(10) primary key,
	tencv nvarchar(40),
	hesopc float,
) 
insert into chucvu
values  ('CV1','Chức vụ 1',3000),
		('CV2','Chức vụ 2',1000),
		('CV3','Chức vụ 3',300),
		('CV4','Chức vụ 4',2000),
		('CV5','Chức vụ 5',3500)
--Phong(maph, tenph, diachiphong, dienthoaiphong)
create table phong(
	maph char(10) primary key,
	tenph nvarchar(40),
	diachiphong nvarchar(40),
	dienthoaiohong nvarchar(12),
)
insert into phong
values  ('PH01','Phòng 1','Hà Nội','0987654321'),
		('PH02','Phòng 2','Hà Nội','0987654322'),
		('PH03','Phòng 3','Hà Nội','0987654312'),
		('PH04','Phòng 4','Hà Nội','0987654333'),
		('PH05','Phòng 5','Hà Nội','0987654123'),
		('PH06','Phòng 1','Nhà A','0987654321')
--Nhanvien(manv, tennv, gioitinh, diachi, hsluong, (macv, maph), Luong, Thuclinh)
create table nhanvien(
	manv char(10),
	tennv nvarchar(30),
	gioitinh nvarchar(5),
	diachi nvarchar(30),
	hsluong float,
	macv char(10) foreign key references chucvu(macv),
	maph char(10) foreign key references phong(maph),
	luong float,
	thuclinh float,
	primary key(manv, macv, maph)
)
insert into nhanvien
values	('nv01','Nhân viên 1','Nữ','Hà Nội',15,'CV1','PH01',20000,19000),
		('nv01','Nhân viên 1','Nữ','Hà Nội',14,'CV3','PH02',23000,18000),
		('nv02','Nhân viên 2','Nam','Hà Nội',15,'CV1','PH03',50000,39000),
		('nv03','Nhân viên 3','Nữ','Hà Nội',16,'CV5','PH05',10000,9000),
		('nv03','Nhân viên 3','Nữ','Hà Nội',10,'CV1','PH01',30000,22000),
		('nv04','Nhân viên 5','Nam','Hà Nội',15,'CV4','PH04',18000,10000)

--2) Hiển thị địa chỉ của phòng có tên là ‘Phòng 4’
	select diachiphong
	from phong
	where tenph = 'Phòng 4'
--3) Tạo view lưu thông tin của phòng ‘Phòng 1’. Thông tin gồm có: Mã nhân viên,tên nhân viên, tên phòng.
	create view tt_phong
	as
		select manv, tennv, tenph
		from nhanvien, phong
		where nhanvien.maph = phong.maph
		and tenph = 'Phòng 1'
	select * from tt_phong
--4) Tạo Trigger tính tiền lương cho nhân viên mỗi khi hệ số lương thay đổi.
	--Biết tiền lương được tính theo công thức: Luong = Hsluong * 1230000
	create trigger tinh_luong on nhanvien
	for update
	as
		update nhanvien
		set luong = hsluong * 1230000
		from nhanvien
--5) Hiển thị thông tin những nhân viên có địa chỉ ở ‘Hải Phòng’. 
	--Thông tin hiển thị gồm có: Mã nhân viên, tên nhân viên, địa chỉ.
	select manv, tennv, diachi
	from nhanvien
	where diachi = 'Hà Nội'
--6) Tạo bổ sung ràng buộc Default cho cột Thuclinh bằng 0
	create default def_thuclinh
	as 
		0
	exec sp_bindefault 'def_thuclinh','nhanvien.thuclinh'
--7) Tạo Trigger tính tiền thực lĩnh cho nhân viên mỗi khi hệ số phụ cấp thay đổi. 
	--Biết thực lĩnh được tính theo công thức: Thuclinh=Luong + Luong * Hesopc
	create trigger tienthuclinh on nhanvien
	for insert
	as
		update nhanvien
		set thuclinh = luong + luong * hesopc
		from nhanvien, chucvu
		where nhanvien.macv = chucvu.macv

	drop trigger tienthuclinh
--8) Hiển thị thông tin những nhân viên thuộc phòng có mã ‘PH05’. 
	--Thông tin hiển thị gồm có: Mã nhân viên, tên nhân viên, địa chỉ của nhân viên.
	select manv, tennv, diachi
	from nhanvien
	where maph = 'PH05'
--9) Tạo bổ sung ràng buộc Default cho cột Diachi là ‘Chưa xác định’
	create default def_diachi
	as
		'Chưa xác định'
	exec sp_bindefault 'def_diachi','nhanvien.diachi'
--10) Tạo Trigger tính tiền lương cho nhân viên .
	--Biết tiền lương được tính theo công thức: Luong = Hsluong * 1230000
	--GIỐNG CÂU 10 
--11) Hiển thị thông tin các phòng có địa chỉ ở ‘Nhà A’. Thông tin hiển thị gồm có: Mã phòng, Tên phòng.
	select maph, tenph
	from pFhong
	where diachiphong = 'Nhà A'
--12) Tạo bổ sung ràng buộc Rule cho cột HesoPC chỉ nhận giá trị từ 0 đến 0.6
	create rule ru_hesopc
	as
		@hesopc between 0 and 0.6
	exec sp_bindrule 'ru_hesopc','chucvu.hesopc'
--13) Tạo thủ tục hiển thị Tên phòng, Tổng số nhân viên của phòng khi biết Mã phòng = 'PH01'
	select tenph, count(*)
	from phong, nhanvien
	where phong.maph = nhanvien.maph
	and nhanvien.maph = 'PH01'
	group by tenph
--14) Hiển thị thông tin những nhân viên không thuộc phòng ‘PH02’. 
	--Thông tin hiển thị gồm có: Mã nhân viên, Tên nhân viên, Mã phòng.
	select manv, tennv, maph
	from nhanvien
	where manv not in (select manv from nhanvien where maph = 'PH02')
--15) Hiển thị thông tin những nhân viên có hệ số lương thấp nhất.
	--Thông tin hiển thị gồm có: Mã nhân viên, Tên nhân viên, Hệ số lương.
	select manv, tennv, hsluong
	from nhanvien
	where hsluong = (select min(hsluong) from nhanvien)
--16) Tạo thủ tục hiển thị Mã nhân viên, Tên nhân viên, Tên chức vụ khi biết Mã chức vụ = 'CV1'
	create proc hienthi @macv char(10)
	as
		select manv, tennv, tencv
		from nhanvien, chucvu
		where nhanvien.macv = chucvu.macv
		and nhanvien.macv = @macv
	exec hienthi 'CV1'
--17) Hiển thị thông tin các phòng không thuộc ‘Nhà A’. Thông tin gồm có: Mã phòng, Tên phòng, Điện thoại phòng.
	select maph, tenph, dienthoaiohong
	from phong
	where maph not in (select maph from phong where diachiphong = 'Nhà A')
--18) Tạo view lưu thông tin nhân viên của phòng 'phòng 5’. Thông tin lưu gồm có: Mã nhân viên, Tên nhân viên, Tên phòng.
	create view tt_nv
	as
		select manv, tennv, tenph
		from nhanvien, phong
		where nhanvien.maph = phong.maph
		and tenph = 'Phòng 5'
	select * from tt_nv
--19) Tạo thủ tục hiển thị Mã nhân viên, Tên nhân viên, Tên phòng khi biết Mã phòng = 'PH05'
	create proc hienthi_tt @maph char(10)
	as
		select manv, tennv, tenph
		from phong, nhanvien
		where phong.maph = nhanvien.maph
		and nhanvien.maph = @maph
	exec hienthi_tt 'PH05'
--20) Backup cơ sở dữ liệu sang ổ đĩa khác.
	backup database Quanlynhanvien_VuThiHoaiThu to disk = 'D:\bai3.bak'