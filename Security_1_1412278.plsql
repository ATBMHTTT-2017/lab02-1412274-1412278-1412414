create table NhanVien
(
  maNV varchar2(10),
  hoTen varchar2(50),
  diaChi varchar2(50),
  dienThoai varchar2(12),
  Email varchar2(50),
  maPhong varchar2(10),
  chiNhanh varchar2(10),
  luong varchar(200),
  khoa varchar (200),
  constraint PK_NhanVien primary key (maNV),
  constraint Check_Luong check (luong >= 0)
);


CREATE OR REPLACE PROCEDURE THEM_NV_LUONG
(
  manv in VARCHAR2,
   hoten in VARCHAR2,
  diachi in VARCHAR2,
  dienthoai in VARCHAR2,
  email in VARCHAR2,
  phongban in VARCHAR2,
  chinhanh in VARCHAR2,
  luong in varchar2,
  khoa in varchar2
)
as
BEGIN
 Declare
    input      VARCHAR(200) := LUONG;
    input_key         varchar(16):= khoa;
    input_raw         raw(2000);
    encrypted_raw     RAW(2000);
    key_raw      RAW(128);
    key_hash raw (2000);
   en_type   PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES128
                                    + DBMS_CRYPTO.CHAIN_CBC
                                    + DBMS_CRYPTO.PAD_pkcs5;
  Begin

    key_raw := UTL_RAW.CAST_TO_RAW (convert(input_key,'AL32UTF8','US7ASCII'));
    key_hash :=  dbms_crypto.hash(key_raw,2);  --Hash MD5
    input_raw := UTL_RAW.CAST_TO_RAW (convert(input_string,'AL32UTF8','US7ASCII'));
    encrypted_raw := DBMS_CRYPTO.ENCRYPT (
                                          src =>input_raw ,
                                          typ => en_type,
                                          key => key_raw
                                          );
  insert into NHANVIEN values(manv,  hoten, diachi, dienthoai, email, phongban, chinhanh, encrypted_raw, key_hash);
  commit;
  End;
END THEM_NV_LUONG;
---ham update Luong va khoa
CREATE OR REPLACE PROCEDURE Updat_LUONG
(
  manv in VARCHAR2,
  luong in varchar2,
  khoa in varchar2
)
as
BEGIN
 Declare
    input      VARCHAR(200) := LUONG;
    input_key         varchar(16):= khoa;
    input_raw         raw(2000);
    encrypted_raw     RAW(2000);
    key_raw      RAW(128);
    key_hash raw (2000);
   en_type   PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES128
                                    + DBMS_CRYPTO.CHAIN_CBC
                                    + DBMS_CRYPTO.PAD_pkcs5;
  Begin

    key_raw := UTL_RAW.CAST_TO_RAW (convert(input_key,'AL32UTF8','US7ASCII'));
    key_hash :=  dbms_crypto.hash(key_raw,2);  --Hash MD5
    input_raw := UTL_RAW.CAST_TO_RAW (convert(input_string,'AL32UTF8','US7ASCII'));
    encrypted_raw := DBMS_CRYPTO.ENCRYPT (
                                          src =>input_raw ,
                                          typ => en_type,
                                          key => key_raw
                                          );
update nhanvien  set luong = encrypted_raw , khoa = key_hash where nhanvien.mannv = manv;
  commit;
  End;
END Updat_LUONG;
-- ham giai ma
CREATE OR REPLACE PROCEDURE XemLuong
(
  manv in varchar2,
  khoa in varchar2
)
 as
begin
declare
  input_key  varchar2(16):= khoa ;
  output VARCHAR2(2000);
  decrypted_raw     RAW(2000);
  encryp_type   PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES128
                                  + DBMS_CRYPTO.CHAIN_CBC
                                  + DBMS_CRYPTO.PAD_pkcs5;
  hash_key raw (2000) := dbms_crypto.hash( UTL_RAW.CAST_TO_RAW (convert(input_key,'AL32UTF8','US7ASCII')),2);


  for vonglap in (select manv,khoa from nhanvien)
  loop
  if  vonglap.manv = manv and hash_key = vonglap.khoa
  then
  decrypted_raw := DBMS_CRYPTO.DECRYPT (
                                        src =>vonglap.Luong,
                                        typ =>  encryption_type,
                                        key => vonglap.khoa);
  output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
    dbms_output.putline(output_string);
    else
    dbms_output.puline('');
  end if;
  end loop;
  end;
-- grant quyen thuc thi cho cac user trong he thong
declare
  temp varchar2(500);
begin
for manv in (select maNV from NhanVien)
loop
  temp := 'grant execute on XemLuong  to ' || manv.maNV;
  execute immediate temp;
end loop;
end;
