/* https://notthedba.wordpress.com/2018/01/06/temporal-tables/ */
/* Scripts used on blog */

USE MISCELLANEOUS
;
GO


SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 
-- School Table created as below,
 
CREATE TABLE [dbo].[School](
    [pkey_School] [int] NOT NULL,
    [SchoolName] [varchar](40) NOT NULL,
    [SchoolDistrict] [char](2) NOT NULL,
    [SchoolRegion] [char](2) NOT NULL,
    [SchoolCountry] [char] (8) NOT NULL,
    [SchoolRole] [int] NOT NULL,
 CONSTRAINT [PK_School] PRIMARY KEY CLUSTERED 
(
    [pkey_School] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
;
GO
 
-- Add some data 
-- District, Region, Country combinations available are:
-- District, Region, Country 
-- D1, R1, England
-- D2, R1, England
-- D3, R1, England
-- D4, R2, England
-- D5, R2, England
-- D6, R3, England
-- D7, R4, Scotland
-- D8, R4, Scotland 
-- D9, R5, Scotland
 
-- All fictional schools, I hope!
 
INSERT dbo.School 
(
    pkey_School,
    SchoolName, 
    SchoolDistrict,
    SchoolRegion,
    SchoolCountry,
    SchoolRole 
)
VALUES
( 1, 'Saint George', 'D1', 'R1', 'England', 432), 
( 2, 'Winston Churchill High',  'D1', 'R1', 'England', 421),
( 3, 'Queen Eliabeth School for Girls',  'D1', 'R1', 'England', 200),
( 4, 'Sir Isaac Newton 6th Form',  'D2', 'R1', 'England', 121),
( 5, 'Carmel High',  'D2', 'R1', 'England', 988),
( 6, 'Blackbooth Cottage Modern',  'D3', 'R1', 'England', 511),
( 7, 'Westbury Moor School',  'D3', 'R1', 'England', 1290),
( 8, 'East Moor School',  'D3', 'R1', 'England', 121),
( 9, 'Killingtn Walk School',  'D4', 'R2', 'England', 82),
( 10, 'Coldwin Technical College',  'D4', 'R2', 'England', 666),
( 11, 'Speak Langauge School',  'D4', 'R2', 'England', 951),
( 12, 'Young Champions Primary',  'D5', 'R2', 'England', 299),
( 13, 'Baggis Junior School',  'D6', 'R3', 'England', 104),
( 14, 'Angel of the North High',  'D6', 'R3', 'England', 681),
( 15, 'Apple Street School',  'D6', 'R3', 'England', 354),
( 16, 'Carfortington Middle School',  'D6', 'R3', 'England', 349),
( 17, 'Saint Patricks High',  'D7', 'R4', 'Scotland', 400),
( 18, 'Our Ladys High',  'D7', 'R4', 'Scotland', 988),
( 19, 'Govan High',  'D7', 'R4', 'Scotland', 1007),
( 20, 'Balloch High',  'D7', 'R4', 'Scotland', 573),
( 21, 'Jamestown High',  'D8', 'R4', 'Scotland', 122),
( 22, 'Bellsmyre High',  'D8', 'R4', 'Scotland', 210),
( 23, 'Saint Brendan of the Calton',  'D8', 'R4', 'Scotland', 1967),
( 24, 'The Davidson Institute',  'D9', 'R5' ,'Scotland', 9)
;
GO 


- Add the columns and options we need to allow the school table
-- to become temporal.
-- We need some defaults for our datetime columns so that we are able
-- to comply with the NOT NULL requirement.
 
ALTER TABLE dbo.School
ADD
fromvalid   datetime2(3) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
CONSTRAINT DFT_School_fromvalid DEFAULT('19000101'),
tovalid     datetime2(3) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
CONSTRAINT DFT_School_tovalid DEFAULT('99991231 23:59:59.999'),
PERIOD FOR SYSTEM_TIME ( fromvalid, tovalid )
;
GO
-- We will see what the use of 'HIDDEN' means shortly.
-- We will also make mention of the use of the chosen precision
-- in the datetime2 columnn
 
-- Now the instruction to mark the table as SYSTEM VERSIONED.
-- With the History Table option, we are telling SQL Server to use
-- the dbo.Audit_School table as our history table. As it does not exist
-- in this database, SQL Server will create it for us.
 
ALTER TABLE dbo.School
SET
    ( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.Audit_School))
;
GO
 
-- Now we were only using the defaults to allow us to add the new
-- datetime2 columns, so we may now drop them.
 
ALTER TABLE dbo.School
DROP CONSTRAINT DFT_School_fromvalid
;
GO
 
ALTER TABLE dbo.School
DROP CONSTRAINT DFT_School_tovalid
;
GO


-- Now where are we?
-- What does our dbo.school table data look like?

SELECT
    *
FROM
    dbo.School
;
GO

-- Where are our new datetime2 columns?
-- Remember the HIDDEN property we used above, when creating the columns.
-- The use of HIDDEN means the the columns won't appear in a SELECT * query.
-- You have to refer to them explicitly in a query to see them and, in any
-- case, your DBA friends will shun you if you continue to use SELECT * queries! 
 
SELECT
    pkey_School     ,
    SchoolName      ,
    fromvalid       ,
    tovalid
 
FROM
    dbo.School
;
GO

-- Lets make some changes to the dbo.School_Table and see the impact on dbo.Audit_School
-- Saint George School has a role of 432. We amend the figure to 435.
UPDATE dbo.School
SET
    SchoolRole = 435
WHERE
    pkey_School = 1
;
GO 
 
SELECT
    pkey_School     ,
    SchoolName      ,
    SchoolRole 
 
FROM
    dbo.School
WHERE
    pkey_School  = 1
;
 
pkey_School SchoolName                                SchoolRole
----------- ---------------------------------------- -----------
          1 Saint George                                     435
 
SELECT
    pkey_School ,
    SchoolName,
    SchoolRole  ,
    fromvalid   ,
    tovalid
FROM
    dbo.Audit_School
;
GO
 
--- The results - The chanage has been recorded in this history table with a tovalid datetime.
--  Note that the SchoolRole value is the older one. The actual value is now 435
pkey_School SchoolName                                SchoolRole fromvalid                   tovalid
----------- ---------------------------------------- ----------- --------------------------- ---------------------------
          1 Saint George                                     432 1900-01-01 00:00:00.000     2018-01-06 20:50:09.778
 
-- Now update the main record again
UPDATE dbo.School
SET
    SchoolRole = 436
WHERE
    pkey_School = 1
;
GO 
 
SELECT
    pkey_School     ,
    SchoolName      ,
    SchoolRole 
 
FROM
    dbo.School
WHERE
    pkey_School  = 1
;
GO
 

-- Check the history table.
SELECT
    pkey_School ,
    SchoolName,
    SchoolRole  ,
    fromvalid   ,
    tovalid
FROM
    dbo.Audit_School
;
GO
 

-- And we see that a new row has appeared.
-- Reading this logically, the value of 432, the original value, was valid until we changed it with our
-- first update , making the school role 435. Our second update to 436 generated the second row,
-- indicating that the value of 435 was valid up to the point where we changed the role to 436.


