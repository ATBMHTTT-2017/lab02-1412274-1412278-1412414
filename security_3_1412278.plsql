--Truong du an chi duoc phep doc, ghi du an minh quan ly
--Mo ket noi Pluggable DB
Alter Pluggable database pdbdb12C open;
--cap quyen truy cap, them cho role truongDuAn
Grant update,select,insert on lab01.ChiTieu  to truongDuAn;
Grant update,select,insert on lab01.DuAn  to truongDuAn;

--cap quyen  cho user lab01 khong bi anh huong boi cac policy
GRANT EXEMPT ACCESS POLICY TO lab01;
--Tao context  nhanvien_ctx
create or replace context nhanvien_ctx  using nhanvien_ctx_pkg;

--Tao package � nhanvien_ctx_pkg
create or replace package nhanvien_ctx_pkg
is
  procedure thongtinnhanvien;
end;


create or replace package body nhanvien_ctx_pkg
is
  procedure thongtinnhanvien
  is
  phongBan varchar2(10);
  latruongphong varchar2(5);
  latruongchinhanh varchar2(5);
  latruongduan varchar2(5);
  begin
    -- Lay phong ban cua nhan vien
    select maPhong into PhongBan from lab01.NhanVien where maNV = sys_context('userenv', 'session_user');
    dbms_session.set_context('nhanvien_ctx', 'phongBan', phongBan);
	--Kiem tra loai nhan vien co phai la truong phong ban hay ko
    select
      case
        when exists(select maPhong from lab01.PhongBan where truongPhong = sys_context('userenv', 'session_user'))
        then 'TRUE'
        else 'FALSE'
      end into latruongphong
    from dual;
    dbms_session.set_context('nhanvien_ctx', 'latruongphong', latruongphong);
    dbms_session.set_context('nhanvien_ctx', 'latruongphong', latruongphong);

    --Kiem tra xem co phai la truong chi nhanh
    select
      case
        when exists(select maCN  from lab01.ChiNhanh where truongChiNhanh = sys_context('userenv', 'session_user'))
        then 'TRUE'
        else 'FALSE'
      end into latruongchinhanh
    from dual;
    dbms_session.set_context('nhanvien_ctx', 'latruongchinhanh', latruongchinhanh);
    dbms_session.set_context('nhanvien_ctx', 'latruongchinhanh', latruongchinhanh);

    --Kiem tra nhan vien co phai la truong du an hay ko
    select
      case
        when exists(select maDA  from lab01.DuAn where truongDA = sys_context('userenv', 'session_user'))
        then 'TRUE'
        else 'FALSE'
      end into latruongduan
    from dual;
    dbms_session.set_context('nhanvien_ctx', 'latruongduan', latruongduan);
    dbms_session.set_context('nhanvien_ctx', 'latruongduan', latruongduan);

    --
    exception
      when no_data_found then null;
  end;
end;


create or replace trigger nhanVien_ctx_trigger after logon on database
begin
  lab01.nhanvien_ctx_pkg.thongtinnhanvien;
end;



--Tao function
create or replace function Doc_Chi_Tieu(object_schema in varchar2, object_name in varchar2)
return varchar2
as
	username varchar2(20);
	phong varchar2(20);
	temp varchar2(100);
	soluongduan number;
	dem number;
begin
	if sys_context('USERENV', 'ISDBA') = 'TRUE' or sys_context('nhanvien_ctx', 'latruongchinhanh') = 'TRUE' or sys_context('nhanvien_ctx', 'latruonphong') = 'TRUE' then	return '';
	end if;
	if sys_context('nhanvien_ctx', 'latruongduan') = 'TRUE' then
		username := sys_context('USERENV', 'SESSION_USER');    -- lay ten user dang log in
--dem so luong du an ma truong du an dang quan ly
		select count(*) into soluongduan from lab01.DuAn where truongDA = username;
		temp := '';
		dem := 0;
		begin
			for da in (select maDA from lab01.DuAn where truongDA = username)
			loop
				dem := dem + 1;
				if dem < soluongduan then
					temp := temp || '''' || da.maDA || '''' || ',';
				end if;
				if dem = soluongduan then
					temp := temp || '''' || da.maDA || '''';
				end if;
			end loop;
		end;
		return 'duAn in (' || temp ||')'; -- tra ve cac nhung du an ma user do quan ly
	end if;
	return '1 = 0';
end;




begin dbms_rls.add_policy (object_schema => 'lab01',
							 object_name => 'ChiTieu', ---Bang nao can gan policy len
							 policy_name => 'Select_Chi_Tieu_DA',
							 function_schema => 'lab01',
							 policy_function => 'Doc_chi_tieu',
							 statement_types => 'select,update');
end;

--xoa 1 policy
begin dbms_rls.drop_policy (object_schema => 'lab01',
                            object_name => 'ChiTieu',
							policy_name => 'Select_Chi_Tieu_DA');
end;

					 select * from ChiTieu;
           select * from phongban;
-- grant quyen

select truongDA from lab01.duan;
begin
for vonglap in (select truongDA from lab01.duan)
 loop
  execute immediate 'grant truongDuAn to' || vonglap.truongDA;
 end loop;
end;
