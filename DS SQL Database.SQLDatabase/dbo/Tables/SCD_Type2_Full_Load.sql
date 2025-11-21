CREATE TABLE [dbo].[SCD_Type2_Full_Load] (
    [SalesRepID]  BIGINT         NULL,
    [RepSourceID] BIGINT         NULL,
    [FirstName]   NVARCHAR (MAX) NULL,
    [LastName]    NVARCHAR (MAX) NULL,
    [Region]      NVARCHAR (MAX) NULL,
    [StartDate]   DATE           NULL,
    [EndDate]     DATE           NULL,
    [IsCurrent]   BIT            NULL,
    [Hash]        NVARCHAR (MAX) NULL
);


GO

