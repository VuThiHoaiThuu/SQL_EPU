create database Quanlybanhang_VuThiHoaiThu
use Quanlybanhang_VuThiHoaiThu

--HANGHOA (Mahang, Tenhang, Donvitinh, Soluong)
create table hanghoa(
	Mahang char(10) primary key,
	Tenhang nvarchar(50),
	donvitinh nvarchar(30),
	soluong int,
) 
insert into hanghoa
values  ('MH01','Hàng 01', 'Chiếc', 5),
		('MH02','Hàng 02', 'Bộ', 10),
		('MH03','Hàng 03', 'Chiếc', 4),
		('MH04','Hàng 04', 'Cái', 6),
		('MH05','Hàng 05', 'Chiếc', 5),
		('MH06','Hàng 06', 'Chiếc', 12)
--HOADON (MaHD, NgayHD, Tienban, Giamgia, Thanhtoan, nguoiban)
create table hoadon(
	MaHD char(10) primary key,
	NgayHD date,
	Tienban float,
	Giamgia float,
	Thanhtoan float,
	nguoiban nvarchar(30),
)
insert into hoadon
values  ('HD01','2/2/2022',4000, 0.5, 2000, 'Tran Thi A'),
		('HD02','2/3/2022',4000, 0.5, 2000, 'Tran Thi A'),
		('HD03','3/2/2022',5000, 0.5, 2000, 'Tran Thi B'),
		('HD04','4/4/2022',3000, 0.5, 1000, 'Tran Thi A'),
		('HD07','1/10/2022',4000, 0.5, 2000, 'Tran Thi D')
--CTHOADON (MaHD, Mahang, Soluong, Dongia)
create table cthoadon(
	MaHD char(10) foreign key references hoadon(MaHD),
	Mahang char(10) foreign key references hanghoa(Mahang),
	Soluong int,
	Dongia float,
	primary key(MaHD, Mahang),
)
insert into cthoadon
values	('HD01','MH01',2, 5000),
		('HD01','MH04',1, 7000),
		('HD02','MH02',3, 8000),
		('HD03','MH03',4, 6000),
		('HD03','MH02',3, 9000),
		('HD04','MH01',5, 5000)

--2) Hiển thị thông tin các mặt hàng có số lượng >10 đơn vị tính.
	select * from hanghoa
	where soluong > 10
--3) Tạo bổ sung ràng buộc Default cho cột NgayHD là ngày hiện tại.
	create default def_ngayHD
	as
		getdate()
	exec sp_bindefault 'def_ngayHD','HoaDon.NgayHD'

--4) Tạo trigger cập nhật lại số lượng hàng trong bảng HANGHOA mỗi khi hàng được bán.
	create trigger capnhat on cthoadon
	for insert
	as
		begin
			declare @sl int, @mahang char(10)
			set @sl = (select soluong from inserted)
			set @mahang = (select mahang from inserted)
			update hanghoa
			set soluong = soluong - @sl
			where mahang = @mahang
		end

--5) Hiển thị số tiền Thanh toán của hóa đơn có mã ‘HD01’
	select Thanhtoan from hoadon
	where MaHD = 'HD01'
--6) Tạo bổ sung ràng buộc Default cho cột Tienban bằng 0
	create default def_tienban
	as
		0
	exec sp_bindefault 'def_tienban','hoadon.tienban'
--7) Tạo trigger cập nhật lại tiền bán của mỗi hóa đơn khi thêm mặt hàng vào bảng
	--CTHOADON. Biết công thức tính Tienban = Sum(Soluong*Dongia)
	create trigger cn_tienban on cthoadon
	for insert
	as
		update hoadon
		set tienban = (select sum(soluong * dongia)
						from cthoadon
						where cthoadon.MaHD = hoadon.MaHD
						group by cthoadon.MaHD)
--8) Hiển thị thông tin các hóa đơn có tiền thanh toán nhỏ nhất.
	select * from hoadon
	where Thanhtoan = (select min(Thanhtoan) from hoadon)
--9) Tạo bổ sung ràng buộc Rule cho cột Soluong của bảng Hanghoa nhận giá trị lớn hơn 0.
	create rule re_soluong
	as
		@soluong > 0
	exec sp_bindrule 're_soluong','hanghoa.soluong'
--10) Tạo Trigger cập nhật lại số tiền cần Thanhtoan khi cột Giamgia thay đổi. Biết công
	--thức tính số tiền cần thanh toán trên mỗi hóa đơn là: Thanhtoan=Tienban-Tienban*Giamgia
	create trigger cn_thanhtoan on hoadon
	for update
	as
		update hoadon
		set Thanhtoan = Tienban - Tienban*Giamgia
--11) Hiển thị thông tin các mặt hàng có đơn vị tính là ‘Chiếc’.
	select * from hanghoa
	where donvitinh = 'Chiếc'
--12) Tạo bổ sung ràng buộc Rule cho cột Donvitinh chỉ nhận các giá trị: Chiếc, Bộ
	create rule ru_donvitinh
	as
		@donvitinh in ('Bộ','Chiếc')
	exec sp_bindrule 'ru_donvitinh','hanghoa.donvitinh'
--13) Tạo trigger cập nhật lại tiền bán của mỗi hóa đơn khi xóa mặt hàng được bán trong
	--bảng CTHOADON. Biết công thức Tienban=Sum(Soluong*Dongia)
	create trigger capnhat_tienban on cthoadon
	for delete
	as
		update hoadon
		set Tienban = ( select sum(Soluong * Dongia)
						from hoadon, cthoadon
						where hoadon.MaHD = cthoadon.MaHD
						group by cthoadon.MaHD)
--14) Hiển thị Mã hàng, Số lượng hàng được bán bởi hóa đơn có mã là ‘HD05’
	select Mahang, Soluong
	from cthoadon
	where MaHD = 'HD05'
--15) Tạo view lưu thông tin các mặt hàng chưa được bán tại cửa hàng. Thông tin gồm có: Mã hàng, Tên hàng, Đơn vị tính.
	create view view_mathang
	as
		select Mahang, tenhang, donvitinh
		from hanghoa
		where Mahang not in (select Mahang from cthoadon)

--16) Tạo trigger cập nhật lại tiền bán của mỗi hóa đơn khi chỉnh sửa lại thông tin mặt
	--hàng được bán trong bảng CTHOADON. Biết công thức tính Tienban=Sum(Soluong*Dongia)
	create trigger cntienban on cthoadon
	for insert
	as
		update hoadon
		set Tienban = ( select sum(Soluong * Dongia)
						from cthoadon
						where hoadon.MaHD = cthoadon.MaHD
						group by cthoadon.MaHD)
--17) Hiển thị Tiền bán của hóa đơn có mã là ‘HD07’
	select Tienban
	from hoadon
	where MaHD = 'HD07'
--18) Hiển thị thông tin mặt hàng được bán với số lượng nhiều nhất tại cửa hàng.
		--Thông tin hiển thị gồm có: Mã hàng, Tên hàng, Tổng số lượng hàng được bán.
		select cthoadon.Mahang, Tenhang, sum(cthoadon.Soluong) as tongsoluong
		from hanghoa, cthoadon
		where hanghoa.Mahang = cthoadon.Mahang
		group by cthoadon.Mahang, Tenhang
		having sum(cthoadon.Soluong) >= all(select sum(Soluong) from cthoadon group by Mahang)
--19) Tạo thủ tục hiển thị thông tin của hàng hóa khi biết mã hàng.
	create proc hienthi @mahang char(10)
	as
		select * from hanghoa 
		where Mahang = @mahang
	exec hienthi 'MH03'
--20) Hiển thị mã hóa đơn được lập trong năm 2022
	select MaHD from hoadon
	where year(NgayHD) = 2022
--21) Hiển thị thông tin mặt hàng được bán với số lượng ít nhất tại cửa hàng. 
		--Thông tin hiển thị gồm có: Mã hàng, tên hàng, tổng số lượng hàng được bán.
	select cthoadon.Mahang, Tenhang, sum(cthoadon.Soluong) as tongsl
	from hanghoa, cthoadon
	where cthoadon.Mahang = hanghoa.Mahang
	group by cthoadon.Mahang, Tenhang
	having sum(cthoadon.Soluong) <= all(select sum(Soluong) from cthoadon group by Mahang)
--22) Tạo thủ tục hiển thị thông tin của hóa đơn khi biết mã hóa đơn.
	--GIỐNG CÂU 19.
--23) Backup cơ sở dữ liệu sang ổ đĩa khác
	backup database Quanlybanhang_VuThiHoaiThu to disk = 'D:\bai2.bak'
	