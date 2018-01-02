-- 1. 打开Forum.sln解决方案，启用Nuget还原，编译解决方案；
-- 2. 在新建的数据库中运行Scripts目录下的InstallDB.sql脚本，创建数据库以及所有的表；
-- 3. 修改Forum.CommandService、Forum.EventService、Forum.Web、Forum.Domain.Tests这些项目的配置文件中的connectionString；
--   确保能连接上面新建的Forum数据库；
-- 4. 将Forum.Web设置为启动项目；
-- 5. 依次启动Forum.NameServerService、Forum.BrokerService、Forum.CommandService、Forum.EventService、Forum.Web这5个工程；
-- 6. 如果要管理论坛版块，需要注册一个名称为admin的账号，注册登录成功后，在右上角就有一个版块管理了；

----------------------------------------------------------------------------------------------
--Tables used by Forum.
----------------------------------------------------------------------------------------------
CREATE DATABASE [Forum_Data]
GO

use [Forum_Data]
GO

CREATE TABLE [dbo].[AccountIndex] (
    [AccountId]   NVARCHAR (32) NOT NULL,
    [AccountName] NVARCHAR (64) NOT NULL,
    CONSTRAINT [PK_AccountIndex] PRIMARY KEY CLUSTERED ([AccountId] ASC)
)
GO
CREATE UNIQUE INDEX [IX_AccountIndex_AccountName] ON [dbo].[AccountIndex] ([AccountName])

CREATE TABLE [dbo].[Account](
    [Id] [nvarchar](32) NOT NULL,
    [Sequence] [bigint] IDENTITY(1,1) NOT NULL,
    [Name] [nvarchar](128) NOT NULL,
    [Password] [nvarchar](128) NULL,
    [CreatedOn] [datetime] NOT NULL,
    [UpdatedOn] [datetime] NOT NULL,
    [Version] [bigint] NOT NULL,
 CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Section](
    [Id] [nvarchar](32) NOT NULL,
    [Sequence] [bigint] IDENTITY(1,1) NOT NULL,
    [Name] [nvarchar](128) NOT NULL,
    [Description] [nvarchar](256) NOT NULL,
    [CreatedOn] [datetime] NOT NULL,
    [UpdatedOn] [datetime] NOT NULL,
    [Version] [bigint] NOT NULL,
 CONSTRAINT [PK_Section] PRIMARY KEY CLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Post](
    [Id] [nvarchar](32) NOT NULL,
    [Sequence] [bigint] IDENTITY(1,1) NOT NULL,
    [Subject] [nvarchar](256) NOT NULL,
    [Body] [ntext] NOT NULL,
    [AuthorId] [nvarchar](32) NOT NULL,
    [SectionId] [nvarchar](32) NOT NULL,
    [CreatedOn] [datetime] NOT NULL,
    [UpdatedOn] [datetime] NOT NULL,
    [MostRecentReplyId] [nvarchar](32) NULL,
    [MostRecentReplierId] [nvarchar](32) NULL,
    [ReplyCount] [bigint] NOT NULL,
    [LastUpdateTime] [datetime] NOT NULL,
    [Version] [bigint] NOT NULL,
 CONSTRAINT [PK_Post] PRIMARY KEY CLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[Reply](
    [Id] [nvarchar](32) NOT NULL,
    [Sequence] [bigint] IDENTITY(1,1) NOT NULL,
    [PostId] [nvarchar](32) NOT NULL,
    [ParentId] [nvarchar](32) NULL,
    [AuthorId] [nvarchar](32) NOT NULL,
    [Body] [ntext] NOT NULL,
    [CreatedOn] [datetime] NOT NULL,
    [UpdatedOn] [datetime] NOT NULL,
    [Version] [bigint] NOT NULL,
 CONSTRAINT [PK_Reply] PRIMARY KEY CLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

----------------------------------------------------------------------------------------------
--Tables used by ENode.
----------------------------------------------------------------------------------------------
CREATE DATABASE [Forum_ENode]
GO
USE [Forum_ENode]
GO

CREATE TABLE [dbo].[EventStream] (
    [Sequence]              BIGINT IDENTITY (1, 1) NOT NULL,
    [AggregateRootTypeName] NVARCHAR (256)         NOT NULL,
    [AggregateRootId]       NVARCHAR (36)          NOT NULL,
    [Version]               INT                    NOT NULL,
    [CommandId]             NVARCHAR (36)          NOT NULL,
    [CreatedOn]             DATETIME               NOT NULL,
    [Events]                NVARCHAR (MAX)         NOT NULL,
    CONSTRAINT [PK_EventStream] PRIMARY KEY CLUSTERED ([Sequence] ASC)
)
GO
CREATE UNIQUE INDEX [IX_EventStream_AggId_Version]   ON [dbo].[EventStream] ([AggregateRootId] ASC, [Version] ASC)
GO
CREATE UNIQUE INDEX [IX_EventStream_AggId_CommandId] ON [dbo].[EventStream] ([AggregateRootId] ASC, [CommandId] ASC)
GO

CREATE TABLE [dbo].[PublishedVersion] (
    [Sequence]                BIGINT IDENTITY (1, 1) NOT NULL,
    [ProcessorName]           NVARCHAR (128)         NOT NULL,
    [AggregateRootTypeName]   NVARCHAR (256)         NOT NULL,
    [AggregateRootId]         NVARCHAR (36)          NOT NULL,
    [Version]                 INT                    NOT NULL,
    [CreatedOn]               DATETIME               NOT NULL,
    CONSTRAINT [PK_PublishedVersion] PRIMARY KEY CLUSTERED ([Sequence] ASC)
)
GO
CREATE UNIQUE INDEX [IX_PublishedVersion_AggId_Version]   ON [dbo].[PublishedVersion] ([ProcessorName] ASC, [AggregateRootId] ASC, [Version] ASC)
GO

CREATE TABLE [dbo].[LockKey] (
    [Name]                   NVARCHAR (128)          NOT NULL,
    CONSTRAINT [PK_LockKey] PRIMARY KEY CLUSTERED ([Name] ASC)
)
GO
