USE Alliant_Claims_Astrus_Stage;

GO

SET ANSI_NULLS ON;

GO

SET ANSI_PADDING ON;

GO

SET QUOTED_IDENTIFIER ON;

GO

DROP PROC IF EXISTS dbo.spaca_aca_payment_attribute_staging_gb_insert;

GO

/*
	Description: Insert Payment Attribute Data to Staging Table GB

	Modification Log:
		10/30/2019	Jonathan Percoma	Initial Version
		11/06/2019	Jonathan Percoma	Update table reference name changes from ref to dbo
		11/11/2019	Jonathan Percoma	Renamed column reference payment_type_description to payment_type
										Renamed column reference check_stock_type to check_stock_type_code
										Renamed column reference check_stock_type_description to check_stock_type
										Renamed table reference aca_gb_payment_type_code to aca_payment_type_code_gb
										Modified INSERT statement to add columns for reference columns SK/PK
										Changed table reference dbo.aca_source_system to ref.aca_source_system
										Changed table reference dbo.aca_check_stock_type to ref.aca_check_stock_type
										Changed table reference dbo.aca_mail_to_code to ref.aca_mail_to_code
										Changed table reference dbo.aca_pay_to_code to ref.aca_pay_to_code
										Changed table reference dbo.aca_payment_type_code_gb to ref.aca_payment_type_code_gb
										Changed column reference mail_to_description to mail_to
										Changed column reference pay_to_description to pay_to
		11/14/2019	Jonathan Percoma	Changed table reference ref.aca_source_system to dbo.aca_source_system
		11/27/2019	Jonathan Percoma	Removed aca_source_system_id filter in @lastLoadDate since this dimension is now using aca_source_system_id_winner

	Test:	TRUNCATE TABLE Alliant_Claims_Astrus_Stage.dbo.aca_payment_attribute_staging_gb;
			GO
			EXEC Alliant_Claims_Astrus_Stage.dbo.spaca_aca_payment_attribute_staging_gb_insert;
			GO
			SELECT TOP 1000 * FROM Alliant_Claims_Astrus_Stage.dbo.aca_payment_attribute_staging_gb;
*/

CREATE PROC dbo.spaca_aca_payment_attribute_staging_gb_insert
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @step VARCHAR(510);
	DECLARE @proc_name SYSNAME = OBJECT_NAME(@@PROCID),
			@current_timestamp DATETIME = CURRENT_TIMESTAMP,
			@errorMessage NVARCHAR(4000),
			@errorSeverity INT,
			@errorState INT;
	DECLARE @sourceSystemIdGb INT = (SELECT aca_source_system_id FROM Alliant_Claims_Astrus.dbo.aca_source_system WHERE source_system = 'GB');
	DECLARE @lastLoadDate DATETIME = (SELECT ISNULL(MAX(aca_date_updated), CAST('1776-07-04 00:00:00.000' AS DATETIME))
									  FROM Alliant_Claims_Astrus.dbo.aca_payment_attribute
									  WHERE aca_payment_attribute_id <> -1);


	BEGIN TRY

		SET @step = N'Step #1: Insert Payment Attribute to Staging';
		INSERT INTO dbo.aca_payment_attribute_staging_gb WITH (TABLOCK)
		(source_system_payment_attribute_id,
		 aca_payment_type_code_id,
		 aca_pay_to_code_id,
		 aca_mail_to_code_id,
		 aca_check_stock_type_id,
		 payment_type_code,
		 payment_type,
		 pay_to_code,
		 pay_to,
		 mail_to_code,
		 mail_to,
		 check_stock_type_code,
		 check_stock_type,
		 check_heading,
		 plan_sequence_number,
		 plan_client_number,
		 gb_internal_use,
		 aca_source_system_id,
		 aca_date_created,
		 aca_create_user,
		 aca_date_updated,
		 aca_update_user)
		SELECT HASHBYTES(N'md5', (SELECT p.payment_type_code, p.pay_to_code, p.mail_to_code,
										 p.check_stock_type_code, p.check_heading,
										 p.plan_sequence_number, p.plan_client_number, p.gb_internal_use
								  FOR XML RAW)) AS [source_system_payment_attribute_id],
			   ty.aca_payment_type_code_gb_id AS [aca_payment_type_code_id],
			   pt.aca_pay_to_code_id,
			   mt.aca_mail_to_code_id,
			   cs.aca_check_stock_type_id,
			   p.payment_type_code,
			   ty.payment_type,
			   p.pay_to_code,
			   pt.pay_to,
			   p.mail_to_code,
			   mt.mail_to,
			   p.check_stock_type_code,
			   cs.check_stock_type,
			   p.check_heading,
			   p.plan_sequence_number,
			   p.plan_client_number,
			   p.gb_internal_use,
			   @sourceSystemIdGb AS [aca_source_system_id],
			   @current_timestamp AS [aca_date_created],
			   @proc_name AS [aca_create_user],
			   @current_timestamp AS [aca_date_updated],
			   @proc_name AS [aca_update_user]
		FROM (SELECT DISTINCT payment_type_code, pay_to_code, mail_to_code,
							  check_stock_type AS [check_stock_type_code], check_heading,
							  plan_sequence_number, plan_client_number, gb_internal_use
			  FROM Alliant_Claims_Astrus.dbo.aca_transaction_payment
			  WHERE aca_date_updated > @lastLoadDate) AS [p]
		LEFT JOIN Alliant_Claims_Astrus.ref.aca_payment_type_code_gb AS [ty]
		ON ty.payment_type_code = p.payment_type_code
		LEFT JOIN Alliant_Claims_Astrus.ref.aca_pay_to_code AS [pt]
		ON pt.pay_to_code = p.pay_to_code
		LEFT JOIN Alliant_Claims_Astrus.ref.aca_mail_to_code AS [mt]
		ON mt.mail_to_code = p.mail_to_code
		LEFT JOIN Alliant_Claims_Astrus.ref.aca_check_stock_type AS [cs]
		ON cs.check_stock_type_code = p.check_stock_type_code;

	END TRY
	BEGIN CATCH

		SET @errorMessage = CONCAT(ERROR_MESSAGE(), N' at ', @step);
	    SET @errorSeverity = ERROR_SEVERITY();
		SET @errorState = ERROR_STATE();

		RAISERROR(@errorMessage, @errorSeverity, @errorState);

	END CATCH;

END;