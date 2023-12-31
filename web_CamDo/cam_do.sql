USE [master]
GO
/****** Object:  Database [QL_Hieu_Cam_Do]    Script Date: 13/09/2023 21:50:11 ******/
CREATE DATABASE [QL_Hieu_Cam_Do]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'QL_Hieu_Cam_Do', FILENAME = N'D:\SQL2014\56KMT\CamDo\QL_Hieu_Cam_Do.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'QL_Hieu_Cam_Do_log', FILENAME = N'D:\SQL2014\56KMT\CamDo\QL_Hieu_Cam_Do_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [QL_Hieu_Cam_Do].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET ARITHABORT OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET  DISABLE_BROKER 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET  MULTI_USER 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET DB_CHAINING OFF 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET DELAYED_DURABILITY = DISABLED 
GO
USE [QL_Hieu_Cam_Do]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_GET_LaiNgay]    Script Date: 13/09/2023 21:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Do Duy Cop
-- Create date: 6.9.2023
-- Description:	Lấy số tiền lãi: theo ngày / 1 triệu
-- =============================================
CREATE FUNCTION [dbo].[FN_GET_LaiNgay]() 
RETURNS Money
AS
BEGIN
	DECLARE @T MONEY;
	
	SELECT @T = CONVERT(MONEY, [value])
	FROM  [Setting]
	WHERE [key] = 'LaiNgay';

	RETURN @T;
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_TienLai]    Script Date: 13/09/2023 21:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Do Duy Cop
-- Create date: 05.09.2023
-- Description:	Tính số tiền gốc+lãi phải trả
-- =============================================
CREATE FUNCTION [dbo].[FN_TienLai]
(
	@SoTien		Money,
	@NgayVay	Date,
	@NgayTra	Date,
	@NgayCC		Date,
	@LaiNgay	Money=5e3
)
RETURNS Money
AS
BEGIN	
	DECLARE @SoNgay INT, @SoNgayCC INT;
	IF (@NgayTra>@NgayCC)
		SELECT @SoNgay=DATEDIFF(DAY, @NgayVay, @NgayCC)+1, @SoNgayCC=DATEDIFF(DAY, @NgayCC, @NgayTra)+1;
	ELSE
		SELECT @SoNgay=DATEDIFF(DAY, @NgayVay, @NgayTra)+1, @SoNgayCC=0;
	SET @SoTien += @SoNgay*(@SoTien/1e6)*@LaiNgay;
	WHILE(@SoNgayCC > 0)
		SELECT @SoTien += (@SoTien/1e6)*@LaiNgay, @SoNgayCC-=1;
	RETURN @SoTien;
END
GO
/****** Object:  Table [dbo].[KhanhHang]    Script Date: 13/09/2023 21:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KhanhHang](
	[makh] [int] IDENTITY(1,1) NOT NULL,
	[TenKH] [nvarchar](50) NOT NULL,
	[SDT] [varchar](50) NOT NULL,
	[DiaChi] [nvarchar](500) NOT NULL,
	[CCCD] [varchar](12) NOT NULL,
	[anh_chup] [image] NULL,
	[created_at] [datetime] NULL CONSTRAINT [DF_KhanhHang_created_at]  DEFAULT (getdate()),
	[updated_at] [datetime] NULL,
 CONSTRAINT [PK_KhanhHang] PRIMARY KEY CLUSTERED 
(
	[makh] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Setting]    Script Date: 13/09/2023 21:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Setting](
	[key] [nvarchar](50) NOT NULL,
	[value] [nvarchar](max) NULL,
	[created_at] [datetime] NULL CONSTRAINT [DF_Setting_created_at]  DEFAULT (getdate()),
	[updated_at] [datetime] NULL,
 CONSTRAINT [PK_Setting] PRIMARY KEY CLUSTERED 
(
	[key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TrangThai]    Script Date: 13/09/2023 21:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrangThai](
	[status] [nvarchar](50) NOT NULL,
	[type] [int] NULL,
	[Note] [nvarchar](50) NULL,
 CONSTRAINT [PK_TrangThai] PRIMARY KEY CLUSTERED 
(
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[VayTien]    Script Date: 13/09/2023 21:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VayTien](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[makh] [int] NOT NULL,
	[SoTienVay] [money] NOT NULL,
	[NgayVayTien] [date] NOT NULL,
	[NgayTraTien] [date] NULL,
	[NgayCC] [date] NOT NULL,
	[TheChap] [nvarchar](500) NOT NULL,
	[SoTienThucTra] [money] NOT NULL,
	[SoTienThucNhan] [money] NOT NULL,
	[Status] [nvarchar](50) NULL,
	[created_at] [datetime] NULL CONSTRAINT [DF_VayTien_created_at]  DEFAULT (getdate()),
	[updated_at] [datetime] NULL,
 CONSTRAINT [PK_VayTien] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[KhanhHang] ON 

GO
INSERT [dbo].[KhanhHang] ([makh], [TenKH], [SDT], [DiaChi], [CCCD], [anh_chup], [created_at], [updated_at]) VALUES (1, N'Đỗ Văn Hiếu', N'0987654321', N'Thái Nguyên', N'0000111', NULL, NULL, NULL)
GO
INSERT [dbo].[KhanhHang] ([makh], [TenKH], [SDT], [DiaChi], [CCCD], [anh_chup], [created_at], [updated_at]) VALUES (2, N'Hoàng Đức Chung', N'113', N'Sơn La', N'001122', NULL, NULL, NULL)
GO
INSERT [dbo].[KhanhHang] ([makh], [TenKH], [SDT], [DiaChi], [CCCD], [anh_chup], [created_at], [updated_at]) VALUES (6, N'Nguyễn Thị Thảo', N'456789', N'Mường Tè', N'1234567', NULL, CAST(N'2023-09-13 13:56:28.570' AS DateTime), NULL)
GO
INSERT [dbo].[KhanhHang] ([makh], [TenKH], [SDT], [DiaChi], [CCCD], [anh_chup], [created_at], [updated_at]) VALUES (11, N'Cốp', N'0981', N'thái nguyên', N'123456789', NULL, CAST(N'2023-09-13 15:19:08.440' AS DateTime), NULL)
GO
INSERT [dbo].[KhanhHang] ([makh], [TenKH], [SDT], [DiaChi], [CCCD], [anh_chup], [created_at], [updated_at]) VALUES (12, N'Tí', N'009', N'abc', N'000', NULL, CAST(N'2023-09-13 15:20:21.520' AS DateTime), NULL)
GO
INSERT [dbo].[KhanhHang] ([makh], [TenKH], [SDT], [DiaChi], [CCCD], [anh_chup], [created_at], [updated_at]) VALUES (13, N'Tèo', N'009123456', N'Hà nội', N'123456', NULL, CAST(N'2023-09-13 15:33:16.997' AS DateTime), NULL)
GO
SET IDENTITY_INSERT [dbo].[KhanhHang] OFF
GO
INSERT [dbo].[Setting] ([key], [value], [created_at], [updated_at]) VALUES (N'LaiNgay', N'5000', CAST(N'2023-09-06 10:41:53.200' AS DateTime), NULL)
GO
INSERT [dbo].[Setting] ([key], [value], [created_at], [updated_at]) VALUES (N'SoNgayCC', N'30', CAST(N'2023-09-06 11:17:07.620' AS DateTime), NULL)
GO
INSERT [dbo].[TrangThai] ([status], [type], [Note]) VALUES (N'TRA_DU_TIEN', 2, N'Đã trả đủ tiền')
GO
INSERT [dbo].[TrangThai] ([status], [type], [Note]) VALUES (N'TRA_THIEU_TIEN', 2, N'Đã trả, những còn thiếu tiền, sẽ lập lượt vay mới')
GO
INSERT [dbo].[TrangThai] ([status], [type], [Note]) VALUES (N'VAY_CHUA_TRA', 1, N'Vay mới, chưa trả tiền')
GO
INSERT [dbo].[TrangThai] ([status], [type], [Note]) VALUES (N'VAY_GAN_NO', 1, N'Vay gán nợ, thực nhận = 0')
GO
SET IDENTITY_INSERT [dbo].[VayTien] ON 

GO
INSERT [dbo].[VayTien] ([id], [makh], [SoTienVay], [NgayVayTien], [NgayTraTien], [NgayCC], [TheChap], [SoTienThucTra], [SoTienThucNhan], [Status], [created_at], [updated_at]) VALUES (1, 1, 10000000.0000, CAST(N'2023-08-20' AS Date), CAST(N'2023-09-05' AS Date), CAST(N'2023-09-17' AS Date), N'laptop cùi bắp', 9000000.0000, 0.0000, NULL, NULL, NULL)
GO
INSERT [dbo].[VayTien] ([id], [makh], [SoTienVay], [NgayVayTien], [NgayTraTien], [NgayCC], [TheChap], [SoTienThucTra], [SoTienThucNhan], [Status], [created_at], [updated_at]) VALUES (2, 2, 5000000.0000, CAST(N'2023-07-01' AS Date), NULL, CAST(N'2023-09-17' AS Date), N'1 qua than', 0.0000, 0.0000, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[VayTien] OFF
GO
ALTER TABLE [dbo].[VayTien]  WITH CHECK ADD  CONSTRAINT [FK_VayTien_KhanhHang] FOREIGN KEY([makh])
REFERENCES [dbo].[KhanhHang] ([makh])
GO
ALTER TABLE [dbo].[VayTien] CHECK CONSTRAINT [FK_VayTien_KhanhHang]
GO
ALTER TABLE [dbo].[VayTien]  WITH CHECK ADD  CONSTRAINT [FK_VayTien_TrangThai] FOREIGN KEY([Status])
REFERENCES [dbo].[TrangThai] ([status])
GO
ALTER TABLE [dbo].[VayTien] CHECK CONSTRAINT [FK_VayTien_TrangThai]
GO
ALTER TABLE [dbo].[VayTien]  WITH CHECK ADD  CONSTRAINT [CK_VayTien] CHECK  (([SoTienVay]>(0)))
GO
ALTER TABLE [dbo].[VayTien] CHECK CONSTRAINT [CK_VayTien]
GO
/****** Object:  StoredProcedure [dbo].[SP_KhachHang]    Script Date: 13/09/2023 21:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Đỗ Duy Cốp
-- Create date: 5.9.23 (ngày khai giảng)
-- Description:	Xử lý thông tin khách hang
-- 1. them_kh: nhập kh mới (tenkh,sdt,diachi,cccd,anh_chup)=> OK, trùng sdt|cccd thì báo lỗi
-- 2. tim_kh: tìm xem sđt/tên/cccd này của kh nào
-- 3. sua_kh: sửa thông tin kh
-- 4. xoa_kh: xóa tt kh (nếu kh này hết nợ thì xóa, còn nợ ko cho xóa)
-- =============================================
CREATE PROCEDURE [dbo].[SP_KhachHang]
	@action varchar(10),
	--các trường để thêm 1 khách hàng
	@tenkh nvarchar(50)=null,
	@sdt varchar(50)=null,
	@diachi nvarchar(500)=null,
	@cccd varchar(12)=null,
	@anh_chup image=null,
	@makh int = null  -- để định vị bản ghi cần sửa/xóa
AS
BEGIN
	if(@action='them_kh')
	begin
		--check trùng sđt hoặc trùng cccd
		if exists(select * from KhanhHang where (sdt=@sdt)or(cccd=@cccd) )
		begin
			select @tenkh=tenKh from KhanhHang where (sdt like '%'+@sdt+'%')or(cccd=@cccd);
			RaisError(N'Trùng SĐT hoặc cccd  của %s rồi!',16,1,@tenkh);
			return;
		end
		--hết trùng thì insert thôi
		insert into KhanhHang(TenKH,SDT,DiaChi,CCCD,anh_chup, created_at)
		values(@TenKH,@SDT,@DiaChi,@CCCD,@anh_chup, getdate());
	end
	else if(@action='ds_kh')
    begin
	  --trả về all danh sách khách hàng
	  select * from KhanhHang
	end
    else if(@action='tim_kh')
    begin
	  --tìm theo: sđt/tên/cccd 
	  select * 
	  from KhanhHang
	  where (@tenkh  = '' and @sdt != '' and @cccd  = '' and sdt   like '%'+@sdt+'%')   --only by @sdt
		  or(@tenkh != '' and @sdt  = '' and @cccd  = '' and tenkh like '%'+@tenkh+'%') --only by @tenkh
	      or(@tenkh  = '' and @sdt  = '' and @cccd != '' and cccd  like '%'+@cccd+'%')  --only by @cccd
		  or(@tenkh  = '' and @sdt  = '' and @cccd  = '')                               --show all
	end
	else if(@action='sua_kh')
    begin
		--check trùng sđt hoặc trùng cccd
		if exists(select * from KhanhHang where (makh!=@makh)and(sdt=@sdt))
		begin
			RaisError(N'Trùng SĐT rồi!',16,1);
			return;
		end
		if exists(select * from KhanhHang where (makh!=@makh)and(cccd=@cccd))
		begin
			RaisError(N'Trùng CCCD rồi!',16,1);
			return;
		end
	  --ko trùng thì đi cập nhật dữ liệu
	  update KhanhHang 
		set TenKH		= @tenkh,
		    SDT			= @SDT,
			DiaChi		= @diachi,
			CCCD		= @CCCD,
			anh_chup	= @anh_chup,
			updated_at	= getdate()
      where makh=@makh;
	end
	else if(@action='xoa_kh')
	begin
	    -- input là mãkh
		-- check xem còn nợ ko: còn nợ <=> trường ngayTraTien = null
		if exists(select * from VayTien where makh=@makh and NgayTraTien is null)
		begin
			RaisError(N'Khách hàng này còn nợ, ko xóa được, xóa thì lấy thông tin đâu mà đòi nợ',16,1);
			return;
		end
		--ko nợ thì xóa ok
		delete from KhanhHang where makh=@makh;
	end
END

GO
/****** Object:  StoredProcedure [dbo].[SP_ThongKe]    Script Date: 13/09/2023 21:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Do Duy Cop
-- Create date: 5.9.23
-- Description:	Các chức năng xử lý liên quan vay/trả tiền
-- 1. ds_vay_chua_tra: thống kê ds KH đang vay, thêm cột số ngày đến Ngày cắt cổ 
-- 2. ds_vay_chua_tra_7: thống kê ds KH đang vay, còn 1 tuần là đến hạn cắt cổ
-- 3. tong_tien_thu_chi: thống kê tổng tiền đã cho vay, tổng tiền đã thu về
-- 4. tong_tien_thu_chi_thang: tính tổng tiền sẽ thu/chi trong 1 tháng nào đó
-- =============================================
CREATE PROCEDURE [dbo].[SP_ThongKe]
	@action varchar(50),
	@mm int=0, @yy int=0  -- tháng/năm cần thống kê tổng thu/chi
AS
BEGIN
	declare @Today date = getdate();
	declare @LaiNgay money;
	if(@action='ds_vay_chua_tra')
	begin
		select @LaiNgay=dbo.FN_Get_LaiNgay();
		select K.*,T.id,T.SoTienVay,T.NgayVayTien,T.NgayCC,
		Datediff(DAY,getdate(),T.NgayCC) as [SoNgay to CC],
		dbo.FN_TienLai(T.SoTienVay, T.NgayVayTien, @Today, T.NgayCC, @LaiNgay) as TongTien
		from VayTien T join KhanhHang K on K.makh=T.makh
		where T.NgayTraTien is null -- NgayTraTien là null <=> chưa trả nợ
		order by [SoNgay to CC]
	end
	--ds kh 1 tuần tới là đến hạn cắt cổ
	if(@action='ds_vay_chua_tra_7')
	begin
		select @LaiNgay=dbo.FN_Get_LaiNgay();
		select *
		from(
			select K.*,T.id,T.SoTienVay,T.NgayVayTien,T.NgayCC,
			Datediff(DAY,getdate(),NgayCC) as [SoNgay to CC],
			dbo.FN_TienLai(T.SoTienVay, T.NgayVayTien, @Today, T.NgayCC, @LaiNgay) as TongTien
			from VayTien T join KhanhHang K on K.makh=T.makh
			where T.NgayTraTien is null
		)as X
		where [SoNgay to CC]>=0 and [SoNgay to CC]<=7
		order by [SoNgay to CC]
	end
	else if (@action='tong_tien_thu_chi')
	begin
		select sum(SoTienThucNhan) as TongChi, --khách hàng thực nhận là do cửa hàng chi ra
			   sum(SoTienThucTra ) as TongThu  --khách hàng thực trả  là nguồn thu của cửa hàng
		From VayTien;
	end
	else if (@action='tong_tien_thu_chi_thang')
	--thu chi trong tháng
	begin
		select
			(	select sum(SoTienThucNhan)
				From VayTien
				where (MONTH(NgayVayTien)=@mm and YEAR(NgayVayTien)=@yy)
			) as TongChi,
			(	select sum(SoTienThucTra)
				From VayTien
				where (MONTH(NgayTraTien)=@mm and YEAR(NgayTraTien)=@yy)
			)as TongThu;
	end
END

GO
/****** Object:  StoredProcedure [dbo].[SP_VayTien]    Script Date: 13/09/2023 21:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Do Duy Cop
-- Create date: 6.9.2023
-- Description:	SP_VayTien
-- 1. vay_tien       : vay tiền lần mới, tiền vay==thực chi
-- 2. tra_du_tien    : trả đủ tiền, hết nợ
-- 3. tra_thieu_tien : trả đủ tiền, hết nợ
-- =============================================
CREATE PROCEDURE [dbo].[SP_VayTien]
	@action		varchar(50)		= null,
	@id_Vay		int				= null,
	@MaKH		int				= null,
	@SoTien		money			= null,
	@NgayVay	date			= null,
	@NgayTra	date			= null,
	@NgayCC		date			= null,
	@TheChap	nvarchar(500)	= null,
	@ThucTra	money			= null,
	@ThucNhan	money			= null
AS
BEGIN
	declare @tien_phai_tra money, @LaiNgay money, @str_full  VARCHAR(40), @str_delta VARCHAR(40);

	if(@action='vay_tien_new')
	begin
		if(@ThucNhan != @SoTien)
		begin
			RaisError(N'Số tiền thực nhận phải bằng số tiền cho vay',16,1);
			Return;
		end
		insert into VayTien(makh,SoTienVay,SoTienThucNhan,NgayVayTien,NgayCC, [status])
		values(@MaKH,@SoTien,@ThucNhan,@NgayVay,@NgayCC, 'VAY_CHUA_TRA')
	end
	if(@action='tra_du_tien')
	begin
		set @LaiNgay=dbo.FN_Get_LaiNgay();
		select @tien_phai_tra = dbo.FN_TienLai(SoTienVay, NgayVayTien, @NgayTra, NgayCC, @LaiNgay) 		
		from VayTien
		where id=@id_Vay and NgayTraTien is null;

		if not(@ThucTra >= @tien_phai_tra)
		begin
			set @str_delta = CAST((@tien_phai_tra-@SoTien) AS VARCHAR(40))
			set @str_full  = CAST(@tien_phai_tra AS VARCHAR(40))
			RaisError(N'Trả thế này thiếu %s. Số tiền phải trả là %s',16,1,@str_delta, @str_full);
			Return;
		end			
		update VayTien set NgayTraTien=@NgayTra, SoTienThucTra = @ThucTra, 
		       [status]='TRA_DU_TIEN', updated_at=getdate()
		where id=@id_Vay;
	end
	if(@action='tra_thieu_tien')
	begin		
		set @LaiNgay=dbo.FN_Get_LaiNgay();
		select @tien_phai_tra = dbo.FN_TienLai(SoTienVay, NgayVayTien, @NgayTra, NgayCC, @LaiNgay) 		
		from VayTien
		where id=@id_Vay and NgayTraTien is null;		
		
		if not(@ThucTra < @tien_phai_tra)
		begin
			set @str_delta = CAST((@SoTien-@tien_phai_tra) AS VARCHAR(40))
			set @str_full  = CAST(@tien_phai_tra AS VARCHAR(40))
			RaisError(N'Trả thế này thừa %s. Số tiền phải trả chỉ là %s',16,1,@str_delta, @str_full);
			Return;
		end
		
		update VayTien set NgayTraTien=@NgayTra, SoTienThucTra = @ThucTra, 
			   [status]='TRA_THIEU_TIEN', updated_at=getdate()
		where id=@id_Vay;

		declare @TienNo money;
		
		select  @TienNo = @tien_phai_tra - @ThucTra, @NgayCC=NgayCC 
		from VayTien 
		where id=@id_Vay;

		if(@NgayCC < @NgayTra) set @NgayCC=@NgayTra;

		insert into VayTien(makh,SoTienVay,SoTienThucNhan,NgayVayTien,NgayCC, [status])
		values(@MaKH,@TienNo,0,@NgayTra,@NgayCC, 'VAY_GAN_NO');

		select IDENT_CURRENT('VayTien'); -- trả về id của lượt vay gán nợ
	end
END

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ngày bắt đầu tính lãi mẹ đẻ lãi con, hết này lại cộng lãi vào mẹ => Đây là ngày cắt cổ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VayTien', @level2type=N'COLUMN',@level2name=N'NgayCC'
GO
USE [master]
GO
ALTER DATABASE [QL_Hieu_Cam_Do] SET  READ_WRITE 
GO
