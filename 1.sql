create database QuanLySinhVien
use QuanLySinhVien
 
--KHOA (MAKHOA_, TENKHOA)
create table khoa(
	makhoa varchar(30) primary key,
	tenkhoa varchar(30),
)
--LOP (MALOP_, TENLOP, SISODK, MAKHOA-)
create table lop(
	malop varchar(20) primary key,
	tenlop varchar(10),
	sisodk int,
	makhoa varchar(30) foreign key references khoa(makhoa),
)
--SINHVIEN (MASV_, HOTEN, NGSINH, DCHI, GIOITINH, MALOP-)
create table sinhvien(
	masv char(10) primary key,
	hoten varchar(30),
	ngsinh date,
	dchi varchar(30),
	gioitinh varchar(5),
	malop varchar(20) foreign key references lop(malop),
)
--MONHOC (MAMH_, TENMH, SOTIET)
create table monhoc(
	mamh varchar(20) primary key,
	tenmh varchar(30),
	sotiet int,
)
--KETQUA (MASV-, MAMH-, DIEM)
create table ketqua(
	masv char(10) foreign key references sinhvien(masv),
	mamh varchar(20) foreign key references monhoc(mamh),
	diem float,
	primary key(masv, mamh),
)

--1. Cho biết tên những môn học có số tiết >=30 và <=90
	select tenmh 
	from monhoc
	where sotiet between 30 and 90
--2. Cho biết họ tên những sinh viên học lớp ‘D15CNPM4’ có điểm thi trong khoảng từ 6 đến 8 điểm
	select distinct hoten 
	from sinhvien, lop, ketqua
	where sinhvien.malop = lop.malop
	and ketqua.masv = sinhvien.masv
	and tenlop = 'D15CNPM4'
	and diem >= 6 and diem <= 8
--3. Cho biết tên những môn học có số tiết <60 và do những sinh viên thuộc khoa ‘CNTT ’ theo học.
	select distinct tenmh
	from monhoc, ketqua, sinhvien, lop, khoa
	where  monhoc.mamh = ketqua.mamh
	and ketqua.masv = sinhvien.masv
	and sinhvien.malop = lop.malop
	and lop.makhoa = khoa.makhoa
	and sotiet < 60
	and tenkhoa = 'CNTT'
--4. Cho biết tên những sinh viên thuộc khoa ‘CNTT’ học môn học có tên là ‘HQTCSDL’ với số điểm <5
	select hoten
	from sinhvien, khoa, ketqua, monhoc, lop
	where monhoc.mamh = ketqua.mamh
	and ketqua.masv = sinhvien.masv
	and sinhvien.malop = lop.malop
	and lop.makhoa = khoa.makhoa
	and tenkhoa = 'CNTT'
	and tenmh = 'HQTCSDL'
	and diem < 5
--5. Liệt kê danh sách tên khoa và số lượng lớp trong từng khoa.
	select tenkhoa, count (malop) as soluong
	from khoa, lop
	where khoa.makhoa = lop.makhoa
	group by tenkhoa
--6. Cho biết họ tên những sinh viên nào học trên 5 môn học.
	select hoten, sinhvien.masv 
	from sinhvien, ketqua
	where sinhvien.masv = ketqua.masv
	group by sinhvien.masv, hoten
	having count (sinhvien.masv) > 5 (select count (masv) as soluongmonhoc
									  from ketqua 
									  group by masv)
--7. Cho biết tên những khoa có nhiều nhất 3 lớp.
	select tenkhoa, khoa.makhoa
	from khoa, lop
	where khoa.makhoa = lop.makhoa
	group by tenkhoa, khoa.makhoa
	having count (lop.makhoa) <= 3 --(select count(*) as soluonglop from khoa group by makhoa)
--8. Cho biết tên những lớp có sĩ số thực ít nhất 30 học sinh.
	select tenlop, lop.malop
	from lop, sinhvien
	where lop.malop = sinhvien.malop
	group by tenlop, lop.malop
	having count (lop.malop) >= 3 --(select count (*) as sisothuc from sinhvien group by malop)

--9. Cho biết tên những khoa có nhiều nhất 100 học sinh.
	select tenkhoa
	from khoa, lop
	where khoa.makhoa = lop.makhoa
	group by tenkhoa
	having sum (sisodk) = 100 --( select sum (sisodk) as sisokhoa from lop group by makhoa)

--10. Cho biết tên những môn học có số tiết > 30 và có ít nhất 8 (30) sinh viên theo học.
	select tenmh, monhoc.mamh
	from monhoc, ketqua, sinhvien
	where monhoc.mamh = ketqua.mamh
	and ketqua.masv = sinhvien.masv
	and sotiet > 30
	group by tenmh, monhoc.mamh
	having count (ketqua.masv) >= 8 --(select count (*) as sinhvientheohoc from ketqua group by mamh)

--11. Cho biết tên những môn học có số tiết lớn nhất.
	select tenmh
	from monhoc 
	where sotiet = (select max(sotiet) from monhoc)

--12. Cho biết tên những sinh viên học nhiều môn học nhất.
	select sinhvien.masv, hoten
	from sinhvien, ketqua
	where sinhvien.masv = ketqua.masv
	group by hoten, sinhvien.masv
	having count (*) >= all  (select count (*) 
							  from ketqua 
							  group by masv) 

--13. Cho biết tên những môn học có nhiều sinh viên theo học nhất.
	select tenmh
	from monhoc, ketqua
	where ketqua.mamh = monhoc.mamh
	group by tenmh
	having count (ketqua.mamh) >= all(select count(*)
									  from ketqua
									  group by mamh)

--14. Cho biết tên những lớp thuộc khoa ‘CNTT’ có số lượng sinh viên ít nhất.
	select tenlop
	from khoa, lop, sinhvien
	where khoa.makhoa = lop.makhoa
	and lop.malop = sinhvien.malop
	and tenkhoa = 'CNTT'
	group by tenlop
	having count(*) <= all(select count(*)
						   from khoa, lop, sinhvien
							where khoa.makhoa = lop.makhoa
							and lop.malop = sinhvien.malop
							and tenkhoa = 'CNTT'
							group by tenlop)

--15. Liệt kê mã sinh viên, họ tên của những sinh viên nữ có điểm trung bình cao nhất.
	select sinhvien.masv, hoten
	from sinhvien, ketqua
	where sinhvien.masv = ketqua.masv
	and gioitinh = 'Nu'
	group by sinhvien.masv, hoten
	having avg(diem) >= all(select avg(diem) 
							from sinhvien, ketqua
							where sinhvien.masv = ketqua.masv
							and gioitinh = 'Nu'
							group by sinhvien.masv, hoten)

--16. Liệt kê danh sách tên những môn học mà chưa có sinh viên nào theo học.
	select tenmh
	from monhoc
	where mamh not in (select mamh from ketqua)

--17. Liệt kê tên những sinh viên chưa học môn có tên là ‘CO SO DU LIEU’.
	select masv, hoten
	from sinhvien    
	where masv not in (select masv 
					   from ketqua, monhoc 
					   where ketqua.mamh = monhoc.mamh and tenmh = 'CO SO DU LIEU')

--18. Liệt kê tên những sinh viên chỉ học môn ‘CO SO DU LIEU’.
	select sinhvien.*
	from sinhvien, monhoc, ketqua
	where sinhvien.masv = ketqua.masv
	and monhoc.mamh = ketqua.mamh
	and tenmh = 'CO SO DU LIEU'
	and ketqua.masv in ( select ketqua.masv 
						from sinhvien,ketqua, monhoc 
						where sinhvien.masv = ketqua.masv
						and ketqua.mamh = monhoc.mamh and tenmh = 'CO SO DU LIEU'
						group by ketqua.masv
						having count(*) = 1)
--cách 2
	select sinhvien.*
	from sinhvien, monhoc, ketqua
	where sinhvien.masv = ketqua.masv
	and monhoc.mamh = ketqua.mamh
	and tenmh = 'CO SO DU LIEU'
	and ketqua.masv not in ( select ketqua.masv 
							from sinhvien,ketqua, monhoc 
							where sinhvien.masv = ketqua.masv
							and ketqua.mamh = monhoc.mamh and tenmh <>'CO SO DU LIEU'
							group by ketqua.masv)

--19. Liệt kê tên những sinh viên nam thuộc khoa ‘CNTT’ hoặc khoa ‘QLNL’ đã học trên 5 môn học.
	select distinct sinhvien.masv, hoten
	from sinhvien, khoa, ketqua, lop
	where khoa.makhoa = khoa.makhoa
	and sinhvien.malop = lop.malop
	and sinhvien.masv = ketqua.masv
	and gioitinh = 'Nam'
	and (tenkhoa = 'CNTT' or tenkhoa = 'QLNL')
	and sinhvien.masv in (select ketqua.masv
							from sinhvien, ketqua
							where sinhvien.masv = ketqua.masv
							group by ketqua.masv
							having count (*) > 5)

--Cách 2
	select distinct hoten
	from sinhvien, khoa, ketqua, lop
	where khoa.makhoa = khoa.makhoa
	and sinhvien.malop = lop.malop
	and sinhvien.masv = ketqua.masv
	and gioitinh = 'Nam'
	and (tenkhoa = 'CNTT' or tenkhoa = 'QLNL')
	group by hoten
	having count (distinct mamh) > 5
--20. Liệt kê tên những lớp có sĩ số thực sự vượt sĩ số dự kiến.
	with res as(select sinhvien.malop, count (*) as 'sisothuc'
				from lop, sinhvien 
				where sinhvien.malop = lop.malop
				group by sinhvien.malop)
	select tenlop
	from res, lop
	where res.malop = lop.malop and res.sisothuc > lop.sisodk






--11.Liệt kê danh sách sinh viên và số lượng lớp trong từng khoa
	select tenkhoa, count(malop) as soluonglop
	from khoa,lop
	where khoa.makhoa = lop.makhoa
	group by tenkhoa

--12.Liệt kê danh sách tên lớp và số lượng sinh viên từng lớp
	select tenlop, count(masv) 
	from lop, sinhvien
	where lop.malop = sinhvien.malop
	group by tenlop

--13.Liệt kê danh sách tên khoa và số lượng sinh viên trong từng khoa
	select tenkhoa, count(masv) as sinhvientungkhoa
	from lop, sinhvien, khoa
	where lop.makhoa = khoa.makhoa
	and lop.malop = sinhvien.malop
	group by tenkhoa

--14.Liệt kê mã sinh viên, họ tên và điểm trung bình của từng sinh viên
	select sinhvien.masv, hoten, avg(diem) as diemtb
	from sinhvien, ketqua
	where sinhvien.masv = ketqua.masv
	group by sinhvien.masv, hoten

--15 Cho biết họ tên những sinh viên nam và tổng số môn học của từng sinh viên này
	select hoten, count(ketqua.mamh)
	from sinhvien, ketqua, monhoc
	where sinhvien.masv = ketqua.masv
	and ketqua.mamh = monhoc.mamh
	and gioitinh = 'Nam'
	group by hoten

--16.Cho biết họ tên những sinh viên nào học trên 2 môn học
	select hoten
	from sinhvien, ketqua, monhoc
	where sinhvien.masv = ketqua.masv
	and ketqua.mamh = monhoc.mamh
	group by hoten
	having count(*) > 2

--17.Cho biết tên những khoa có ít nhất 3 lớp
	select tenkhoa
	from khoa, lop
	where khoa.makhoa = lop.makhoa
	group by tenkhoa
	having count (malop) > 3

--18 Cho biết tên những lớp có sĩ số thực ít nhất 3 học sinh
	select tenlop
	from lop, sinhvien
	where lop.malop = sinhvien.malop
	group by tenlop
	having count (masv) >= 3
--19.Khoa có nhiều nhất 5 học sinh
	select tenkhoa
	from sinhvien, khoa, lop
	where sinhvien.malop = lop.malop
	and khoa.makhoa = khoa.makhoa
	group by tenkhoa
	having count(masv) <= 5
--20.Tên môn học có số tiết > 30 và có ít nhất 2 sinh viên theo học
	select tenmh
	from monhoc, sinhvien, ketqua
	where monhoc.mamh = ketqua.mamh
	and sinhvien.masv = ketqua.masv
	and sotiet > 30
	group by tenmh
	having count(ketqua.masv) >= 2
-- Tạo bảng sv_lop
	create table sv_lop(
	masv char(10) foreign key references sinhvien(masv),
	tenlop varchar(10) ,
	primary key(masv))
	-- thêm vào bảng sv_lop những sinh viên học lop1
	insert into sv_lop
	select masv, hoten
	from sinhvien, lop
	where sinhvien.malop = lop.malop
	and tenlop = 'lop1'
--Thêm vào bảng sv_lop những sinh viên nam lop d15cnpm4 có điểm trung bình > 7
	insert into sv_lop
	select sinhvien.masv, hoten
	from sinhvien, lop, ketqua
	where sinhvien.masv = ketqua.masv
	and sinhvien.malop = lop.malop
	and gioitinh = 'Nam'
	and tenlop = 'D15CNPM4'
	group by sinhvien.masv, hoten
	having avg(diem) > 7
--sinh viên có điểm nhỏ hơn 4 là 3 môn và điểm trung bình < 5.5
--Cách 1
	insert into sv_lop
	select sinhvien.masv, hoten
	from sinhvien, ketqua
	where sinhvien.masv = ketqua.masv
	and ketqua.masv in (select masv
						from ketqua
						where diem < 4
						group by masv
						having count (mamh) = 3)
	group by sinhvien.masv, hoten
	having avg(diem) < 5.5

--Cách 2
	insert into sv_lop
	select sinhvien.masv, hoten
	from sinhvien, ketqua
	where sinhvien.masv = ketqua.masv
	and diem < 4
	group by sinhvien.masv, hoten 
	having avg(diem) < 5.5 and count(ketqua.masv) = 3


--KHAI BÁO BIẾN điểm trung bình gán giá trị điểm trung bình môn cơ sở dữ liệu lớp d15cnpm4
	declare @dtb float
	set @dtb = (select avg(diem) 
				from ketqua, lop, monhoc, sinhvien
				where ketqua.masv = sinhvien.masv
				and ketqua.mamh = monhoc.mamh
				and sinhvien.malop = lop.malop
				and tenlop = 'D15CNPM4'
				and tenmh = 'CO SO DU LIEU')
	print @dtb
--KHAI BÁO BIẾN somonhoc để lưu trữ số môn học có điểm < 8 của sinh viên lớp D15cnpm4
	declare @somonhoc int
	set @somonhoc = (select count(mamh)
					from sinhvien, ketqua, lop
					where sinhvien.masv = ketqua.masv
					and sinhvien.malop = lop.malop
					and diem < 8
					and tenlop = 'D15CNPM4'
					and hoten = 'LE THANH KIET')
	print @somonhoc 

--29/09/2022 
	create default def_ssdk
	as 
		20
	exec sp_bindefault def_ssdk, 'lop.sisodk'
	exec sp_unbindefault 'lop.sisodk'
	drop default def_ssdk
--Tạo giá trị mặc định malop là D16CNPM1. và hủy giá trị mặc định đó
	create default def_tenlop
	as
		'D16CNPM1'
	exec sp_bindefault def_tenlop, 'lop.tenlop'
	exec sp_unbindefault 'lop.tenlop'
	drop default def_tenlop

	create rule rule_Diemso
	as
		@diem between 0 and 10
	sp_bindrule 'rule_Diemso', 'ketqua.diem'
	sp_unbindrule 'ketqua.diem'
	drop rule rule_Diemso
--Tạo luật trong bảng sinhvien có gioitinh là nam/nu
	create rule rule_gioitinh
	as
		@gioitinh between 'Nu' and 'Nam'
	sp_bindrule 'rule_gioitinh', 'sinhvien.gioitinh'
	sp_unbindrule 'sinhvien.gioitinh'
	drop rule rule_gioitinh
	--Cách 2
	create rule rule_gioitinh
	as
		@gioitinh in ('Nam', 'Nu')
	sp_bindrule 'rule_gioitinh', 'sinhvien.gioitinh'
	sp_unbindrule 'sinhvien.gioitinh'


	--10/10/2022
--Danh sách môn học có số tiết > 30.
	if(select count(*) from monhoc
		where sotiet > 30) > 0
	  begin
		print 'danh sach mon hoc co so tiet > 30 la: '
		select mamh, tenmh
		from monhoc
		where sotiet > 30
	  end
	else
		print 'Khong co mon hoc nao co so tiet > 30.. '

-- Danh sach sinh vien có điểm > 5
	if exists (select * from ketqua
				where diem > 5)
	  begin
	print 'danh sach sinh vien co diem thi > 5'
		select distinct hoten
		from sinhvien, ketqua
		where ketqua.masv = sinhvien.masv
		and diem > 5
	  end
	else
		print 'Khong co sinh vien nao co diem thi > 5'

-- danh sach sinh viên đạt loại giỏi (điểm tb >= 8)
	if exists (select ketqua.masv
				from ketqua, monhoc
				where monhoc.mamh = ketqua.mamh
				group by ketqua.masv
				having  sum(diem * (sotiet/15)) / sum(sotiet/15) >= 8
				) 
	  begin
		print 'Danh sach sinh vien dat loai gioi: '
			select ketqua.masv, hoten,  sum(diem * (sotiet/15))/ sum(sotiet/15) as dtb
			from ketqua, monhoc, sinhvien
			where sinhvien.masv = ketqua.masv
			and monhoc.mamh = ketqua.mamh
			group by ketqua.masv, hoten
			having sum(diem * (sotiet/15)) / sum(sotiet/15) >= 8
	  end
	else
		print 'Khong co sinh vien nao loai gioi'


--Sử dụng câu lệnh while đưa ra màn hình những sinh viên có điểm < 5
	
	declare @dem int
	set @dem = (select count(*) from ketqua where diem < 5)
	while @dem > 0
		begin
			select hoten
			from sinhvien, ketqua
			where sinhvien.masv = ketqua.masv
			and diem < 5
			set @dem = @dem - 1
		end


--Sử dụng while hiển thị những sinh viên có điểm trung bình < 5
	declare @a int
	set @a = (select count(*) from ketqua where diem > 0)
	while @a > 0
		begin
			select hoten, avg(diem) as dtb
			from sinhvien, ketqua
			where sinhvien.masv = ketqua.masv
			group by hoten
			having avg(diem) < 5
			set @a = @a - 1
		end

--Kiểm tra có bạn Nguyen Van A không nếu không thì thêm dữ liệu
	declare @x int
	set @x = (select count(*) from sinhvien where hoten = 'Nguyen Van A')
	while @x < 0
		begin 
			insert into sinhvien(masv, hoten, ngsinh, dchi, gioitinh, malop)
			values ('sv222', 'Nguyen Van A', '2000-03-03', 'Thai Nguyen', 'Nam', 'lop1')
		end


	--24/10/2022
--Hiển thị danh sách môn học có số tiết > 20
	create procedure ds_mh
	as
		select mamh, tenmh
		from monhoc
		where sotiet > 20
	exec ds_mh
	drop procedure ds_mh --Xóa thủ tục

--Tạo cột sĩ số trong bảng lớp, viết thủ tục update sĩ số thực tế của lớp vào bảng
	alter table lop
	add siso int
	create procedure sisothuc
	as
		update lop
		set siso = (select count(*)
					from sinhvien
					where sinhvien.malop = lop.malop
					group by sinhvien.malop)
	exec sisothuc
	drop procedure sisothuc

--Hiển thị thông tin sinh viên mã sv1
	create procedure KQ_SV @masv char(10)
	as
		select masv, mamh, diem
		from ketqua
		where masv = @masv
	exec KQ_SV 'sv1'
	drop procedure KQ_SV
	print @masv

--đưa ra kết quả học tập có mã 'mh1', mã sv 'sv1'
	create proc KQ @mamh varchar(20), @masv char(10)
	as
		select masv, mamh, diem
		from ketqua
		where mamh = @mamh and masv = @masv
	exec KQ 'mh1', 'sv1'
	drop proc KQ 


	create proc xem_diem @masv char(10), @mamh varchar(20), @diem float output
	as
		select @diem = diem
		from ketqua
		where masv = @masv and mamh = @mamh
		declare @diemsv float
			exec xem_diem 'sv1', 'mh1', @diemsv output
	print @diemsv
	drop proc xem_diem

--Đưa ra điểm trung bình theo từng môn học của lớp D15CNPM4
	create proc xem_dtb @malop varchar(20), @dtb float output
	as 
		select @dtb = avg(diem)
		from ketqua, lop
		where malop = @malop 
		declare @diem_tb float
			exec xem_dtb 'D15CNPM4', @diem_tb output
		print @diem_tb
	drop proc xem_dtb


--lệnh return tạo cả pro
create proc tt_sv @masv varchar(10)
as
	if @masv is null
	begin
		print 'hay nhap ma sinh vien'
		return
		end
	else
		begin
		select *
		from sinhvien
		where masv = @masv
		end
exec tt_sv '001'
exec tt_sv null
drop proc tt_sv


--trigger
create trigger ktra_siso on lop
--[with encryption]
for insert
as
	if(select siso from inserted) < 0
		begin
		print 'siso cua lop phai > 0'
		rollback tran
		end
drop trigger ktra_siso

--vidu capnhat
create trigger capnhat_siso on sinhvien
for insert 
	as
	update lop
	set siso = (select count (*)
				from sinhvien
				where sinhvien.malop = lop. malop
				group by sinhvien.malop)

insert into sinhvien
values ('011', 'x', '', 'nam', 'cnpm7')
insert into sinhvien
values ('012', 'a', '', 'nam', 'cnpm7')

select siso
from lop
where malop = 'cnpm7'


--vidu xoa (xoa xong se luu vao bang sv_xoa)
create table sv_xoa(
masv varchar(10) primary key,
 hoten varchar (30),
 ngsinh date,
 gt varchar(5),
 malop varchar(10) foreign key references lop (malop)
)
create trigger chuyen_dl on sinhvien
for delete 
as
	insert into sv_xoa
	select *from deleted

select * from sinhvien
select * from sv_xoa

delete from sinhvien
where masv = '005'

--vidu xoa chi vai thuoc tinh trong bang
create table sv_xoa1(
masv varchar(10) primary key,
 hoten varchar (30),
 gt varchar(5)
)
create trigger chuyen_dl1 on sinhvien
for delete 
as
	insert into sv_xoa1
	select masv, hoten, gioitinh from deleted

select * from sinhvien
select * from sv_xoa1

delete from sinhvien
where masv = '007'


--vidu update
alter table sinhvien
add dtb float 
create trigger cn_diem on ketqua
for update
as
	begin
	update sinhvien
	set dtb = (select avg(diem)
				from ketqua
				where ketqua.masv = sinhvien.masv
				group by ketqua.masv)
	end
select * from sinhvien where masv = '001'
update ketqua set diem = 10 where masv = '001' and mamh = '001'

--dùng được cả 3 lệnh update, delete, insert trong 1 trigger
create trigger cn_diem1 on ketqua
for update, insert, delete 
as
	begin
	update sinhvien
	set dtb = (select avg(diem)
				from ketqua
				where ketqua.masv = sinhvien.masv
				group by ketqua.masv)
	end 

select * from sinhvien where masv = '001'
select * from ketqua

insert into ketqua
values ('001','001', 16)

delete from ketqua
where masv= '001' and mamh = '001'

