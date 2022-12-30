create database Quanlykhachsan_VuThiHoaiThu
use Quanlykhachsan_VuThiHoaiThu

--PHONG (MAPH, TENPH, DT, GIAPHONG)
create table phong( 
	maph char(10) primary key,
	tenph nvarchar(40),
	dt float,
	giaphong float,
) 
insert into phong
values	('PH01','Phòng 1','23',10000),
		('PH02','Phòng 2','25',50000),
		('PH03','Phòng 3','15',30000),
		('PH04','Phòng 4','34',70000),
		('PH05','Phòng 5','25',90000),
		('PH06','Phòng 6','16',10000)
--KHACHHANG (MAKH, TENKH, DIACHI)
create table khachhang(
	makh char(10) primary key,
	tenkh nvarchar(40),
	diachi nvarchar(40),
)
insert into khachhang
values  ('KH01','Khách hàng 1','Hà Nội'),
		('KH02','Khách hàng 2','Hà Nam'),
		('KH03','Khách hàng 3','Thái Bình'),
		('KH04','Khách hàng 4','Hà Nội'),
		('KH05','Khách hàng 5','Hà Nội'),
		('KH06','Khách hàng 6','Hà Nội')
--THUEPHONG (MAHD, MAKH, MAPH, NGBD, NGKT,THANHTIEN)
create table thuephong(
	mahd char(10),
	makh char(10) foreign key references khachhang(makh),
	maph char(10) foreign key references phong(maph),
	ngaybd date,
	ngaykt date,
	thanhtien float,
	primary key(mahd, makh),
)
insert into thuephong
values  ('HD01','KH01','PH01','4/4/2022','12/4/2022',12000),
		('HD01','KH02','PH03','9/9/2022','12/10/2022',18000),
		('HD02','KH02','PH02','4/4/2022','12/4/2022',12000),
		('HD03','KH03','PH04','4/4/2022','12/4/2022',12000),
		('HD02','KH01','PH05','4/4/2022','12/4/2022',12000),
		('HD04','KH05','PH05','4/4/2022','12/4/2022',12000),
		('HD01','KH04','PH01','4/4/2022','12/4/2022',12000)
--2) Hiển thị thông tin của các khách hàng (MAKH,TENKH,DIACHI) chưa bao giờ thuê phòng.
	select khachhang.makh, tenkh, diachi
	from khachhang
	where makh not in (select makh from thuephong)
--3) Tạo bổ sung ràng buộc Defaul cho cột THANHTIEN bằng 0.
	create default def_thanhtien
	as
		0
	exec sp_bindefault 'def_thanhtien','thuephong.thanhtien'
--4) Tạo thủ tục hiển thị thông tin của các Khách hàng (MAKH,TENKH, DIACHI) 
	--khi biết mã phòng (MAPH = PH01) và ngày bắt đầu thuê phòng(NGBD=4/4/2022)
	create proc hienthi @maph char(10), @ngbd date
	as
		select khachhang.* from khachhang,thuephong
		where khachhang.makh = thuephong.makh
		and  maph = @maph
		and ngaybd = @ngbd
	exec hienthi 'PH01', '4/4/2022'
--5) Hiển thị thông tin của các phòng (MAPH, TENPH, GIAPHONG) chưa bao giờ được khách hàng thuê.
	select maph, tenph, giaphong
	from phong
	where maph not in (select maph from thuephong)
--6) Tạo bổ sung ràng buộc Rule cho cột GIAPHONG >=5.
	create rule ru_giaphong
	as
		@giaphong >= 5
	exec sp_bindrule 'ru_giaphong','phong.giaphong'
--7) Tạo thủ tục hiển thị thông tin của các PHONG (MAPH, TENPH, DT, GIAPHONG) có ít khách hàng thuê nhất.
	create proc hienthi_tt
	as
		select phong.maph, tenph, dt, giaphong from phong, thuephong
		where phong.maph = thuephong.maph
		group by phong.maph, tenph, dt, giaphong
		having count(*) <= all(select count(*) from thuephong group by maph )
	exec hienthi_tt
	drop proc hienthi_tt
--8) Hiển thị thông tin của những khách hàng (MAKH,TENKH,DIACHI) đã thuê phòng có mã phòng(MAPH) =‘PH02’.
	select khachhang.* 
	from khachhang, thuephong
	where maph = 'PH02'
	and khachhang.makh = thuephong.makh
--9) Tạo bổ sung ràng buộc Defaul DIACHI là ‘CHUA XAC DINH’.
	create default def_diachi
	as
		'Chưa xác định'
	exec sp_bindefault 'def_diachi','khachhang.diachi'
--10) Tạo trigger thực hiện kiểm tra ngày bắt đầu (NGBD) và ngày kết thúc (NGKT) 
	--khi thêm hay sửa phải thỏa mãn lớn hơn hoặc bằng ngày hiện tại.
	create trigger kt on thuephong
	for insert, update
	as
		begin
		declare @ngbd date = (select ngaybd from inserted)
		declare @ngkt date = (select ngaykt from inserted)
		if(@ngbd >= getdate() and @ngkt >= getdate())
			begin
			print 'Nhap lai ngay bat dau va ngay ket thuc'
			rollback tran
			end
		end
--11) Hiển thị thông tin của các phòng (MAPH, TENPH, DT, GIAPHONG) do khách hàng có mã khách hàng (MAKH) = ‘KH02’ thuê.
	select phong.* from phong, thuephong
	where makh = 'KH02'
	and phong.maph = thuephong.maph
--12) Tạo View hiển thị thông tin của Khách hàng (TENKH) có địa chỉ ‘HA NOI’.
	create view ht_tt_kh
	as
		select tenkh
		from khachhang where diachi = 'Hà Nội'
	select * from ht_tt_kh
--13) Tạo Trigger tự động cập nhật thành tiền (THANHTIEN) mỗi khi thêm dữ liệu vào bảng THUEPHONG 
	--cho biết THANHTIEN=GIAPHONG*SONGAY.
	create trigger capnhat_thongtin on thuephong
	for insert,update
	as
		begin
			declare @maph char(10) = (select maph from inserted)
			declare @giaphong float = (select giaphong from phong where maph = @maph)
			update thuephong
			set thanhtien = (datediff(day, ngaybd, ngaykt)) * @giaphong
		end
	drop trigger cn_tt
--14) Hiển thị thông tin của các phòng (MAPH, TENPH, GIAPHONG) được thuê ngày bắt đầu(NGBD) là ngày ‘2022-09-10’.
	select phong.* from phong, thuephong
	where phong.maph = thuephong.maph
	and ngaybd = '2022-9-9'
--15) Tạo View hiển thị tên khách hàng(TENKH) và số lượng phòng mà các khách hàng đó thuê.
	create view ht_tenkh
	as
		select tenkh, count(*) as soluong
		from khachhang, thuephong
		where khachhang.makh = thuephong.makh
		group by tenkh
	select * from ht_tenkh
--16) Tạo thủ tục hiển thị thông tin của PHONG(MAPH, TENPH, DT, GIAPHONG) khi biết mã phòng (MAPH) = PH03
	create proc ht_thongtin @maph char(10)
	as
		select * from phong where maph = 'PH03' and maph = @maph
	exec ht_thongtin 'PH03'
--17) Hiển thị thông tin của các PHONG (MAPH, TENPH, DT) có ngày thuê là 10 ngày.
	select phong.* from phong, thuephong
	where phong.maph = thuephong.maph
	and datediff(day, ngaybd, ngaykt) = 10
--18) Tạo View hiển thị thông tin của các phòng (MAPH, TENPH, DT, GIAPHONG) có giá phòng cao nhất.
	create view ht_thongtinphong
	as
		select * from phong
		where giaphong = (select max(giaphong) from phong)
	select * from ht_thongtinphong
--19) Tạo thủ tục xóa các PHONG chưa bao giờ được thuê
	create proc xoaphong
	as
		begin
		delete from phong
		where maph not in (select maph from thuephong)
		end
	exec xoaphong
	drop proc xoaphong
--20) Hiển thị thông tin của những khách hàng (MAKH,TENKH,DIACHI) đã thuê phòng có mã phòng(MAPH) =‘PH02’.
	select khachhang.* from khachhang, thuephong
	where khachhang.makh = thuephong.makh
	and maph = 'PH02'
--21) Tạo View hiển thị tên khách hàng(TENKH) và số lượng phòng mà các khách hàng đó thuê.
	create view vw_ht_tt
	as
		select tenkh, count(*) as soluong
		from khachhang, thuephong
		where khachhang.makh = thuephong.makh
		group by tenkh
	select * from vw_ht_tt
--22) Tạo Trigger tự động cập nhật thành tiền (THANHTIEN) 
	--mỗi khi thêm dữ liệu vào bảng THUEPHONG cho biết THANHTIEN=GIAPHONG*SONGAY
	create trigger capnhat_thanhtien on thuephong
	for insert, update
	as
		begin 
			declare @maph char(10) = (select maph from inserted)
			declare @giaphong float = (select giaphong from phong where maph = @maph)
			update thuephong
			set thanhtien = (datediff(day, ngaybd, ngaykt)) * @giaphong
		end
	drop trigger capnhat_thanhtien
--23) Backup cơ sở dữ liệu sang ổ đĩa khác.
	backup database Quanlykhachsan_VuThiHoaiThu to disk = 'D:\bai5.bak'