create database Quanlydulich_VuThiHoaiThu
use Quanlydulich_VuThiHoaiThu
 
--DIADIEM(MADD, TENDD,TP)
create table diadiem(
	madd char(10) primary key,
	tendd nvarchar(40),
	tp nvarchar(30),
)
insert into diadiem 
values  ('DD01','Ba Vì','Hà Nội'),
		('DD02','Văn Miếu','Hà Nội'),
		('DD03','Lăng Bác','Hà Nội'),
		('DD04','Hồ Tây','Hà Nội'),
		('DD05','Nha Trang','Khánh Hòa')
--CHUYENDI(MACD, TENCD, NGKH, NGKT, KHDK)
create table chuyendi(
	macd char(10) primary key,
	tencd nvarchar(40),
	ngkh date,
	ngkt date,
	khdk int,
)
insert into chuyendi
values  ('CD01','Chuyến đi 1','9/9/2022','10/10/2022',20),
		('CD02','Chuyến đi 2','8/9/2022','1/10/2022',40),
		('CD03','Chuyến đi 3','9/8/2022','3/10/2022',30),
		('CD04','Chuyến đi 4','1/9/2022','12/9/2022',50),
		('CD05','Chuyến đi 5','9/11/2022','10/10/2022',5)
--CTIETCD(MACD, MADD, SNLUU)
create table ctietcd(
	macd char(10) foreign key references chuyendi(macd),
	madd char(10) foreign key references diadiem(madd),
	snluu int,
)
insert into ctietcd
values  ('CD01','DD01',10),
		('CD02','DD01',30),
		('CD01','DD04',15),
		('CD03','DD03',22),
		('CD04','DD05',18),
		('CD05','DD05',21)

--2) Hiển thị các địa điểm du lịch (MADD, TENDD) của chuyến đi có mã ‘CD01’.
	select diadiem.madd, tendd
	from diadiem, ctietcd
	where diadiem.madd = ctietcd.madd
	and macd = 'CD01'
--3) Tạo View hiển thị thông tin Tên chuyến đi (TENCN) và Số lượng địa điểm của các chuyến đi đó.
	create view ht_tt_cd
	as
		select tencd, count(*) as soluongdd
		from chuyendi, ctietcd
		where chuyendi.macd = ctietcd.macd
		group by tencd
	select * from ht_tt_cd
--4) Viết trigger thực hiện kiểm tra ngày khởi hành (NGKH) và ngày kết thúc 
	--(NGKT) trên bảng chuyến đi khi thêm hay sửa phải thỏa mãn lớn hơn hoặc bằng ngày hiện tại.
	create trigger kiemtra on chuyendi
	for insert, update 
	as
		begin
		declare @ngaykh date = (select ngkh from inserted)
		declare @ngaykt date = (select ngkt from inserted)
		if(@ngaykh < getdate() and @ngaykt < getdate())
			begin
				print 'Nhap lai ngay khoi hanh va ket thuc'
				rollback tran
			end
		end
--5) Hiển thị số ngày lưu lại lớn nhất, nhỏ nhất qua các điểm du lịch của chuyến đi có mã ‘CD01’.
	select max(snluu) as songayluumax, min(snluu) as songayluumin
	from chuyendi, ctietcd
	where chuyendi.macd = ctietcd.macd
	and ctietcd.macd = 'CD01'
--6) Tạo View hiển thị thông tin của các chuyến đi bao gồm: 
	--Mã chuyến đi, Tên chuyến đi (MACD,TENCD) có ngày khởi hành (NGKH) trong năm 2022.
	create view ht_tt_chuyendi
	as
		select macd, tencd
		from chuyendi
		where year(ngkh) = 2022
	select * from ht_tt_chuyendi
--7) Tạo thủ tục hiển thị thông tin của địa điểm khi biết mã địa điểm (MaDD) = 'DD05'
	create proc hienthi @madd char(10)
	as
		select * from diadiem
		where madd = @madd
	exec hienthi 'DD05'
--8) Hiển thị mã chuyến đi, mã địa điểm và số ngày lưu (MACD,MADD,SNLUU)với điều kiện có số ngày lưu lại (SNLUU ) nhỏ nhất.
	select macd, madd, snluu
	from ctietcd
	where snluu = (select min(snluu) from ctietcd)
--9) Tạo bổ sung ràng buộc Defaul cho cột SNLUU bằng 0.
	create default def_snluu
	as
		0
	exec sp_bindefault 'def_snluu','ctietcd.snluu'
--10) Tạo thủ tục hiển thị thông tin của chuyến đi khi biết mã chuyến đi(MaCD) = 'CD02'
	create proc hienthi_tt @macd char(10)
	as
		select * from chuyendi
		where macd = @macd
	exec hienthi_tt 'CD02'
--11) Hiển thị thông tin của các chuyến đi bao gồm:  (MACD, TENCD) có ngày khởi hành (NGKH) là ngày 2022/9/9
	select macd, tencd from chuyendi
	where ngkh = '09-09-2022'
--12) Tạo bổ sung ràng buộc Defaul cho cột NGKH bằng ngày hiện tại.
	create default def_ngkh
	as
		getdate()
	exec sp_bindefault 'def_ngkh','chuyendi.ngkh'
--13) Tạo thủ tục hiển thị tên chuyến đi (TENCD) và số lượng địa điểm của chuyến đi khi biết mã chuyến đi (MACD) = 'CD01'.
	create proc hienthi_cd @macd char(10)
	as
		select tencd, count(*) as soluongdd
		from chuyendi, ctietcd
		where chuyendi.macd = ctietcd.macd
		and ctietcd.macd = @macd
		group by tencd
	exec hienthi_cd 'CD01'
--14) Hiển thị thông tin của các chuyến đi bao gồm: Mã chuyến đi, Tên chuyến đi (MACD,TENCD) có số khách dự kiến nhiều nhất.
	select macd, tencd
	from chuyendi
	where khdk = (select max(khdk) from chuyendi)
--15) Viết trigger thực hiện kiểm tra số ngày lưu lại (SNLUU) trên bảng CTIETCD khi thêm hay sửa phải thỏa mãn SNLUU>=0.
	create trigger kiemtra_snluu on ctietcd
	for insert, update
	as
		begin
		declare @snluu int = (select snluu from inserted)
		if(@snluu < 0)
			begin
				print 'Nhap lai ngay luu lai'
				rollback tran
			end
		end

	drop trigger kiemtra_snluu
--16) Hiển thị thông tin của các địa điểm bao gồm: Mã địa điểm, Tên địa điểm (MADD,TENDD) thuộc thành phố ‘hà nội’.
	select madd, tendd
	from diadiem
	where tp = 'Hà Nội'
--17) Tạo bổ sung ràng buộc Rule cho cột NGKH,NGKT >= ngày hiện tại.
	create rule ru_ngay
	as 
		@ngay >= getdate()
	exec sp_bindrule 'ru_ngay','chuyendi.ngkh'
	exec sp_bindrule 'ru_ngay','chuyendi.ngaykt'
--18) Viết trigger thực hiện kiểm tra số khách đăng ký (KHDK) trên bảng CHUYENDI khi thêm hay sửa phải thỏa mãn KHDK>=5.
	create trigger kt on chuyendi
	for insert, update
	as
		begin
		declare @khdk int = (select khdk from inserted)
		if(@khdk < 5)
			begin 
			print 'So khach dang ki phai >= 5'
			rollback tran
			end
		end
--19) Backup cơ sở dữ liệu sang ổ đĩa khác.
	backup database Quanlydulich_VuThiHoaiThu to disk = 'D:\bai4.bak'