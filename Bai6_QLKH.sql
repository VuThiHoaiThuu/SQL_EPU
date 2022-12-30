create database QLKH_VTHT
use QLKH_VTHT

create table giangvien(
	gv char(10) primary key,
	hoten nvarchar(30),
	diachi nvarchar(50), 
	ngaysinh date, 
)
insert into giangvien
values  ('GV01','Lê Hoàn','Mỹ Đình, Hà Nội','10/10/1982'),
		('GV02','Phương Văn Cảnh','Nam Từ Liêm, Hà Nội','11/03/1986'),
		('GV03','Phạm Quang Huy','Đống Đa, Hà Nội','06/04/1990'),
		('GV04','Bùi Khánh Linh','Tây Hồ, Hà Nội','12/10/1993'),
		('GV05','Lê Trang Linh','Đống Đa, Hà Nội','10/10/1986')

create table detai(
	dt char(10) primary key,
	tendt nvarchar(50),
	cap nvarchar(30),
	kinhphi float,
)
insert into detai
values  ('DT01','Nhận dạng khuôn mặt','Nhà nước',800),
		('DT02','Tính toán lưới','Bộ',500),
		('DT03','An toàn thông tin','Bộ',370),
		('DT04','Xây dựng hệ thống eleaning','Trường',20)

create table thamgia(
	gv char(10) foreign key references giangvien(gv),
	dt char(10) foreign key references detai(dt),
	sogio int,
)
insert into thamgia
values  ('GV01','DT01',100),
		('GV01','DT02',80),
		('GV01','DT04',80),
		('GV02','DT01',120),
		('GV02','DT03',140),
		('GV03','DT03',150),
		('GV04','DT04',180)

--2) Đưa ra thông tin giảng viên có địa chỉ ở quận “Đống Đa”, sắp xếp theo thứ tự giảm dần của họ tên.
	select * from giangvien
	where diachi like 'Đống Đa,%'
	order by hoten DESC
--3) Tạo view có tên vw_DeTai_loc bao gồm tên đề tài, kinh phí. Và chỉ liệt kê những đề tài có kinh phí >300.
	create view vw_Detai_loc
	as
		select tendt, kinhphi
		from detai
		where kinhphi > 300
	select * from vw_Detai_loc
--4) Giảng viên có mã GV04 không tham gia bất kỳ đề tài nào nữa. Hãy xóa tất cả thông tin liên quan đến giảng viên này trong CSDL.
	delete from thamgia where gv = 'GV04'
	delete from giangvien where gv = 'GV04'
--5) Đưa ra danh sách gồm họ tên, địa chỉ, ngày sinh của giảng viên có tham gia vào đề tài “Tính toán lưới”.
	select hoten, diachi, ngaysinh
	from giangvien, thamgia, detai
	where giangvien.gv = thamgia.gv
	and detai.dt = thamgia.dt
	and tendt = 'Tính toán lưới'
--6) Tạo thủ tục hiển thị Tên đề tài của những đề tài có kinh phí nhỏ hơn số chỉ định, 
	--nếu không có thì hiển thị thông báo không có đề tài nào.
	create proc hienthi_tendt @kinhphi float
	as
		begin
		if exists (select tendt from detai where kinhphi < @kinhphi)
			begin
			select tendt
			from detai
			where kinhphi < @kinhphi
			end
		else 
			print 'Không có đề tai nào'
		end
	exec hienthi_tendt 100
--7) Giảng viên Nguyễn Khánh Tùng sinh ngày 08/09/1985 địa chỉ Đống Đa, Hà Nội mới tham gia nghiên cứu đề tài khoa học. 
	--Hãy thêm thông tin giảng viên này vào bảng GiangVien.
	insert into giangvien
	values ('GV06','Nguyễn Khánh Tùng','Đống Đa, Hà Nội','09/08/1985')
--8) Đưa ra danh sách gồm họ tên, địa chỉ, ngày sinh của giảng viên có tham gia vào 
	--đề tài “An toàn thông tin” hoặc “Nhận dạng khuôn mặt”.
	select hoten, diachi, ngaysinh
	from thamgia, giangvien, detai
	where thamgia.gv = giangvien.gv
	and detai.dt = thamgia.dt
	and tendt = 'Nhận dạng khuôn mặt'
--9) Tạo một Trigger để kiểm tra số giờ phải lớn hơn 30, nếu không thì hiển thị không nhập được.
	create trigger kiemtra on thamgia
	for insert, update
	as
		begin
		declare @sogio float = (select sogio from thamgia)
		if(@sogio < 30)
			begin
				print 'Không thể nhập'
				rollback tran
			end
		end
--10) Giảng viên Lê Hoàn mới chuyển về sống tại quận Cầu Giấy, Hà Nội. Hãy cập nhật thông tin này.
	update giangvien
	set diachi = 'Cầu Giấy, Hà Nội'
	where hoten = 'Lê Hoàn'

	select * from giangvien where hoten = 'Lê Hoàn'
--11) Cho biết thông tin giảng viên tham gia ít nhất 2 đề tài.
	select giangvien.gv, hoten, diachi, ngaysinh
	from giangvien, thamgia
	where giangvien.gv = thamgia.gv
	group by giangvien.gv, hoten, diachi, ngaysinh
	having count(*) >= 2
--12) Đưa ra mã giảng viên, tên giảng viên và tổng số giờ tham gia nghiên cứu khoa học của từng giảng viên.
	select giangvien.gv, hoten, sum(sogio) as tongsogio
	from thamgia, giangvien
	where thamgia.gv = giangvien.gv
	group by giangvien.gv, hoten
--13) Cho biết tên giảng viên tham gia ít đề tài nhất.
	select hoten
	from thamgia, giangvien
	where thamgia.gv = giangvien.gv
	group by hoten
	having count(dt) <= all(select count(*) from thamgia group by dt)
--14) Dùng view vw_DT để liệt kê tên những đề tài cấp Bộ
	create view vw_DT
	as
		select tendt
		from detai
		where cap = 'Bộ'
	select * from vw_DT
--15) Cho biết tên những giảng viên sinh trước năm 1987 và có tham gia đề tài “An toàn thông tin”.
	select hoten
	from giangvien, thamgia, detai
	where giangvien.gv = thamgia.gv
	and thamgia.dt = detai.dt
	and year(ngaysinh) < 1987
	and tendt = 'An toàn thông tin'
--16) Đề tài nào tốn nhiều kinh phí nhất?
	select * from detai
	where kinhphi = (select max(kinhphi) from detai)
--17) Cho biết tên và ngày sinh của giảng viên sống ở Mỹ Đình và tên các đề tài mà giảng viên này tham gia.
	select hoten, ngaysinh, tendt
	from detai, giangvien, thamgia
	where detai.dt = thamgia.dt
	and giangvien.gv = thamgia.gv
	and diachi like 'Mỹ Đình,%'
--18) Tạo View vw_HT để hiển thị thông tin của đề tài và giảng viên thực hiện biết mã đề tài là “DT02”
	create view vw_HT
	as
		select detai.*, giangvien.*
		from detai, giangvien, thamgia
		where detai.dt = thamgia.dt
		and giangvien.gv = thamgia.gv
		and detai.dt = 'DT02'
	select * from vw_HT
--19) Đề tài nào tốn ít kinh phí nhất?
	select *
	from detai
	where kinhphi = (select min(kinhphi) from detai)
--20) Đưa ra toàn bộ thông tin tên đề tài, giảng viên tham gia, kinh phí, số giờ, cấp.
	select tendt, hoten, kinhphi, sogio, cap
	from detai, thamgia, giangvien
	where detai.dt = thamgia.dt
	and giangvien.gv = thamgia.gv
--21) Tạo View vw_HT_GV để hiển thị thông tin của giảng viên và đề tài giảng viên thực hiện có mã giảng viên “GV03”
	create view vw_HT_GV
	as
		select giangvien.*, tendt
		from giangvien, detai, thamgia
		where giangvien.gv = thamgia.gv
		and detai.dt = thamgia.dt
		and thamgia.gv = 'GV03'
	select * from vw_HT_GV
--22) Hãy đưa ra thông tin của đề tài có Kinh phi nhỏ nhất.
	select detai.*
	from detai
	where kinhphi = (select min(kinhphi) from detai)
--23) Hãy thêm cột thành tiền cho bảng ThamGia.
	alter table thamgia
	add thanhtien float
	alter trigger capnhat on thamgia
	for insert, update
	as
		begin
			declare @sogio float = (select sogio from inserted)
			declare @gv char(10) = (select gv from inserted)
			declare @dt char(10) = (select dt from inserted)
			declare @thanhtien float = @sogio * 80000
			update thamgia set thanhtien = @thanhtien where gv = @gv and dt = @dt
		end
	select * from thamgia
	update thamgia set sogio = 20 where gv = 'GV06' and dt = 'DT03'
--25) Hãy backup cơ sở dữ liệu sang ổ đĩa khác trong máy tính.
	backup database QLKH_VTHT to disk = 'D:\bai5.bak'