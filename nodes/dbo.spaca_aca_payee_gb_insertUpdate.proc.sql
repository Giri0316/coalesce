USE Alliant_Claims_Astrus_Stage;

GO

SET ANSI_NULLS ON;

GO

SET ANSI_PADDING ON;

GO

SET QUOTED_IDENTIFIER ON;

GO

DROP PROC IF EXISTS dbo.spaca_aca_payee_gb_insertUpdate;

GO

/*
	Description: Insert and Update Payee GB Dimension

	Modification Log:
		11/01/2019	Jonathan Percoma	Initial Version
		11/05/2019	Jonathan Percoma	Changed data_source_id column name to aca_source_system_id
		11/12/2019	Jonathan Percoma	Added column aca_irs_form_1099_type_id
										Renamed reference to column irs_form_1099_type to irs_form_1099_type_code
										Renamed reference to column irs_form_1099_type_description to irs_form_1099_type

	Test: EXEC Alliant_Claims_Astrus_Stage.dbo.spaca_aca_payee_gb_insertUpdate;
		  GO
		  SELECT TOP 1000 * FROM Alliant_Claims_Astrus.dbo.aca_payee_gb;
*/

CREATE PROC dbo.spaca_aca_payee_gb_insertUpdate
AS
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @step VARCHAR(510);
	DECLARE @proc_name SYSNAME = OBJECT_NAME(@@PROCID),
			@current_timestamp DATETIME = CURRENT_TIMESTAMP,
			@errorMessage NVARCHAR(4000),
			@errorSeverity INT,
			@errorState INT;
	DECLARE @certificate INT = CERT_ID('Certificate1');
	DECLARE @authenticator VARCHAR(3) = '123';





	BEGIN TRY

		SET @step = N'Step #1: Start Explicit Transaction';
		BEGIN TRAN

			SET @step = N'Step #2: Insert New Records';
			INSERT INTO Alliant_Claims_Astrus.dbo.aca_payee_gb
			(source_system_payee_id,
			 aca_irs_form_1099_type_id,
			 payee_type,
			 payee_encrypted,
			 last_name_encrypted,
			 first_name_encrypted,
			 organization_encrypted,
			 address_encrypted,
			 city,
			 state_code,
			 zip_code,
			 country_code,
			 irs_tax_identification_number_encrypted,
			 irs_form_1099_type_code,
			 irs_form_1099_type,
			 mail_to_type,
			 mail_to_encrypted,
			 mail_to_last_name_encrypted,
			 mail_to_first_name_encrypted,
			 mail_to_organization_encrypted,
			 mail_to_address_encrypted,
			 mail_to_city,
			 mail_to_state_code,
			 mail_to_zip_code,
			 mail_to_country_code,
			 aca_source_system_id,
			 aca_date_created,
			 aca_create_user,
			 aca_date_updated,
			 aca_update_user)
			SELECT s.source_system_payee_id,
				   s.aca_irs_form_1099_type_id,
				   s.payee_type,
				   s.payee_encrypted,
				   s.last_name_encrypted,
				   s.first_name_encrypted,
				   s.organization_encrypted,
				   s.address_encrypted,
				   s.city,
				   s.state_code,
				   s.zip_code,
				   s.country_code,
				   s.irs_tax_identification_number_encrypted,
				   s.irs_form_1099_type_code,
				   s.irs_form_1099_type,
				   s.mail_to_type,
				   s.mail_to_encrypted,
				   s.mail_to_last_name_encrypted,
				   s.mail_to_first_name_encrypted,
				   s.mail_to_organization_encrypted,
				   s.mail_to_address_encrypted,
				   s.mail_to_city,
				   s.mail_to_state_code,
				   s.mail_to_zip_code,
				   s.mail_to_country_code,
				   s.aca_source_system_id,
				   @current_timestamp AS [aca_date_created],
				   @proc_name AS [aca_create_user],
				   @current_timestamp AS [aca_date_updated],
				   @proc_name AS [aca_update_user]
			FROM dbo.aca_payee_staging_gb AS [s]
			LEFT JOIN Alliant_Claims_Astrus.dbo.aca_payee_gb AS [t]
			ON t.source_system_payee_id = s.source_system_payee_id
			AND t.aca_source_system_id = s.aca_source_system_id
			WHERE t.aca_payee_gb_id IS NULL;



			SET @step = N'Step #3: Update Existing Records';
			UPDATE t
			SET t.aca_irs_form_1099_type_id = s.aca_irs_form_1099_type_id,
				t.last_name_encrypted = s.last_name_encrypted,
				t.first_name_encrypted = s.first_name_encrypted,
				t.organization_encrypted = s.organization_encrypted,
				t.address_encrypted = s.address_encrypted,
				t.city = s.city,
				t.state_code = s.state_code,
				t.zip_code = s.zip_code,
				t.country_code = s.country_code,
				t.irs_form_1099_type_code = s.irs_form_1099_type_code,
				t.irs_form_1099_type = s.irs_form_1099_type,
				t.mail_to_type = s.mail_to_type,
				t.mail_to_encrypted = s.mail_to_encrypted,
				t.mail_to_last_name_encrypted = s.mail_to_last_name_encrypted,
				t.mail_to_first_name_encrypted = s.mail_to_first_name_encrypted,
				t.mail_to_organization_encrypted = s.mail_to_organization_encrypted,
				t.mail_to_address_encrypted = s.mail_to_address_encrypted,
				t.mail_to_city = s.mail_to_city,
				t.mail_to_state_code = s.mail_to_state_code,
				t.mail_to_zip_code = s.mail_to_zip_code,
				t.mail_to_country_code = s.mail_to_country_code,
				t.aca_date_updated = @current_timestamp,
				t.aca_update_user = @proc_name
			FROM Alliant_Claims_Astrus.dbo.aca_payee_gb AS [t]
			INNER JOIN dbo.aca_payee_staging_gb AS [s]
			ON s.source_system_payee_id = t.source_system_payee_id
			AND s.aca_source_system_id = t.aca_source_system_id
			WHERE t.aca_date_created <> @current_timestamp
			AND (ISNULL(t.aca_irs_form_1099_type_id, -1) = ISNULL(s.aca_irs_form_1099_type_id, -1)
				 OR ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, t.last_name_encrypted, 1, @authenticator) AS VARCHAR(256)), '') <> ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, s.last_name_encrypted, 1, @authenticator) AS VARCHAR(256)), '')
				 OR ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, t.first_name_encrypted, 1, @authenticator) AS VARCHAR(256)), '') <> ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, s.first_name_encrypted, 1, @authenticator) AS VARCHAR(256)), '')
				 OR ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, t.organization_encrypted, 1, @authenticator) AS VARCHAR(256)), '') <> ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, s.organization_encrypted, 1, @authenticator) AS VARCHAR(256)), '')
				 OR ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, t.address_encrypted, 1, @authenticator) AS VARCHAR(256)), '') <> ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, s.address_encrypted, 1, @authenticator) AS VARCHAR(256)), '')
				 OR ISNULL(t.city, '') <> ISNULL(s.city, '')
				 OR ISNULL(t.state_code, '') <> ISNULL(s.state_code, '')
				 OR ISNULL(t.zip_code, '') <> ISNULL(s.zip_code, '')
				 OR ISNULL(t.country_code, '') <> ISNULL(s.country_code, '')
				 OR ISNULL(t.irs_form_1099_type_code, '') <> ISNULL(s.irs_form_1099_type_code, '')
				 OR ISNULL(t.irs_form_1099_type, '') <> ISNULL(s.irs_form_1099_type, '')
				 OR ISNULL(t.mail_to_type, '') <> ISNULL(s.mail_to_type, '')
				 OR ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, t.mail_to_encrypted, 1, @authenticator) AS VARCHAR(256)), '') <> ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, s.mail_to_encrypted, 1, @authenticator) AS VARCHAR(256)), '')
				 OR ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, t.mail_to_last_name_encrypted, 1, @authenticator) AS VARCHAR(256)), '') <> ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, s.mail_to_last_name_encrypted, 1, @authenticator) AS VARCHAR(256)), '')
				 OR ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, t.mail_to_first_name_encrypted, 1, @authenticator) AS VARCHAR(256)), '') <> ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, s.mail_to_first_name_encrypted, 1, @authenticator) AS VARCHAR(256)), '')
				 OR ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, t.mail_to_organization_encrypted, 1, @authenticator) AS VARCHAR(256)), '') <> ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, s.mail_to_organization_encrypted, 1, @authenticator) AS VARCHAR(256)), '')
				 OR ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, t.mail_to_address_encrypted, 1, @authenticator) AS VARCHAR(256)), '') <> ISNULL(CAST(DECRYPTBYKEYAUTOCERT(@certificate, NULL, s.mail_to_address_encrypted, 1, @authenticator) AS VARCHAR(256)), '')
				 OR ISNULL(t.mail_to_city, '') <> ISNULL(s.mail_to_city, '')
				 OR ISNULL(t.mail_to_state_code, '') <> ISNULL(s.mail_to_state_code, '')
				 OR ISNULL(t.mail_to_zip_code, '') <> ISNULL(s.mail_to_zip_code, '')
				 OR ISNULL(t.mail_to_country_code, '') <> ISNULL(s.mail_to_country_code, ''));


		SET @step = N'Step #4: Explicit Commit Transaction';
		COMMIT TRAN;

	END TRY
	BEGIN CATCH

		SET @errorMessage = CONCAT(ERROR_MESSAGE(), N' at ', @step);
	    SET @errorSeverity = ERROR_SEVERITY();
		SET @errorState = ERROR_STATE();

		IF XACT_STATE() <> 0
			ROLLBACK TRAN;

		RAISERROR(@errorMessage, @errorSeverity, @errorState);

	END CATCH;

END;