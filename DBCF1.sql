USE [QLCF1]
GO
/****** Object:  StoredProcedure [dbo].[USP_GetAccountbyUserName]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_GetAccountbyUserName]
@username nvarchar(100)
as 
BEGIN
	SELECT * FROM Account WHERE Username = @username
	END 

GO
/****** Object:  StoredProcedure [dbo].[USP_GetTableList]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[USP_GetTableList]
as select * from TableDrink

GO
/****** Object:  StoredProcedure [dbo].[USP_InsertBill]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_InsertBill]
@idTable INT
AS
BEGIN
	INSERT Bill(DateCheckIn, DateCheckOut, idTable, status, discount)
	VALUES (GETDATE(), NULL, @idTable, 0, 0)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_InsertBillInfo]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_InsertBillInfo]
@idBill INT, @idFood INT, @count INT
AS
BEGIN

	DECLARE @isExitsBillInfo INT
	DECLARE @foodCount INT = 1

	SELECT  @isExitsBillInfo = id, @foodCount = b.count 
	FROM BillInfo AS b 
	WHERE idBill = @idBill and idFood = @idFood

	IF (@isExitsBillInfo > 0)
	BEGIN 
		DECLARE @newCount INT = @foodCount + @count
		IF (@newCount > 0)
			UPDATE BillInfo SET COUNT = @foodCount + @count WHERE idFood = @idFood
		ELSE
			DELETE BillInfo WHERE idBill = @idBill AND idFood = @idFood
	END
	ELSE
	BEGIN
		INSERT INTO BillInfo(idBill, idFood, count)
		VALUES (@idBill,@idFood,@count)
	END
END

GO
/****** Object:  StoredProcedure [dbo].[USP_Login]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_Login]
@username nvarchar(100), @password nvarchar(100)
AS
BEGIN 
SELECT * FROM Account WHERE Username = @username and PassWord = @password
END

GO
/****** Object:  StoredProcedure [dbo].[USP_SwitchTable]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- proc chuyen ban (không có)
CREATE PROC [dbo].[USP_SwitchTable]
@idTable1 INT, @idTable2 int
AS BEGIN

	DECLARE @idFirstBill int
	DECLARE @idSeconrdBill INT
	
	DECLARE @isFirstTablEmty INT
	DECLARE @isSecondTablEmty INT
	
	
	SELECT @idSeconrdBill = id FROM dbo.Bill WHERE idTable = @idTable2 AND status = 0
	SELECT @idFirstBill = id FROM dbo.Bill WHERE idTable = @idTable1 AND status = 0

	IF (@idFirstBill IS NULL)
	BEGIN

		INSERT Bill(DateCheckIn,DateCheckOut,idTable,status)
		VALUES (GETDATE(),NULL,@idTable1,0)
		        
		SELECT @idFirstBill = MAX(id) FROM dbo.Bill WHERE idTable = @idTable1 AND status = 0
		
	END
	
	SELECT @isFirstTablEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idFirstBill
	
	IF (@idSeconrdBill IS NULL)
	BEGIN

		INSERT Bill(DateCheckIn,DateCheckOut,idTable,status)
		VALUES (GETDATE(),NULL,@idTable2,0)

		SELECT @idSeconrdBill = MAX(id) FROM dbo.Bill WHERE idTable = @idTable2 AND status = 0
		
	END
	
	SELECT @isSecondTablEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idSeconrdBill

	SELECT id INTO IDBillInfoTable FROM dbo.BillInfo WHERE idBill = @idSeconrdBill
	
	UPDATE dbo.BillInfo SET idBill = @idSeconrdBill WHERE idBill = @idFirstBill
	
	UPDATE dbo.BillInfo SET idBill = @idFirstBill WHERE id IN (SELECT * FROM IDBillInfoTable)
	
	DROP TABLE IDBillInfoTable
END

GO
/****** Object:  Table [dbo].[Account]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[Username] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](100) NOT NULL DEFAULT (N'Kter'),
	[PassWord] [nvarchar](1000) NOT NULL DEFAULT ((0)),
	[Type] [int] NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Bill]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bill](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DateCheckIn] [date] NOT NULL DEFAULT (getdate()),
	[DateCheckOut] [date] NULL,
	[idTable] [int] NOT NULL,
	[status] [int] NOT NULL DEFAULT ((0)),
	[discount] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BillInfo]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idBill] [int] NOT NULL,
	[idFood] [int] NOT NULL,
	[count] [int] NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Drink]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Drink](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL DEFAULT (N'Chưa đặt tên'),
	[idCategory] [int] NOT NULL,
	[price] [float] NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DrinkCategory]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DrinkCategory](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL DEFAULT (N'Chưa đặt tên'),
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TableDrink]    Script Date: 12/29/2022 9:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TableDrink](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL DEFAULT (N'Bàn chưa có tên'),
	[status] [nvarchar](100) NOT NULL DEFAULT (N'Trống'),
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Bill]  WITH CHECK ADD FOREIGN KEY([idTable])
REFERENCES [dbo].[TableDrink] ([id])
GO
ALTER TABLE [dbo].[BillInfo]  WITH CHECK ADD FOREIGN KEY([idBill])
REFERENCES [dbo].[Bill] ([id])
GO
ALTER TABLE [dbo].[BillInfo]  WITH CHECK ADD FOREIGN KEY([idFood])
REFERENCES [dbo].[Drink] ([id])
GO
ALTER TABLE [dbo].[Drink]  WITH CHECK ADD FOREIGN KEY([idCategory])
REFERENCES [dbo].[DrinkCategory] ([id])
GO
