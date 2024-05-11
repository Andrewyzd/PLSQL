CREATE OR REPLACE PROCEDURE print_article(pubid IN CHAR) AS
	--Cursor declaration using publication_master table
	CURSOR cursor_merged_publication IS
		SELECT * FROM publication_master;

	v_merged_publication cursor_merged_publication%ROWTYPE;
	--declare variable and initialise boolean to false
	publication_isExist BOOLEAN := false;
	publication_category CHAR(12);
	--declare exception for non exist publication
	publication_not_found EXCEPTION;
	PRAGMA EXCEPTION_INIT(publication_not_found, -20001);
	
	--procedure to display the details of articles which are under same categories
	PROCEDURE displayArticle(publication_category IN CHAR) AS
		--Cursor declaration using publication_master table
		CURSOR cursor_merged_publication IS
			SELECT * FROM publication_master WHERE type = 'Article' ORDER BY TO_NUMBER(detail_2)ASC;
		
		v_merged_publication cursor_merged_publication%ROWTYPE;
		--assign the current publication category to the variable
		current_publication_category CHAR(12):= publication_category;
	BEGIN
		--Display the appropriate column name based on article details
		DBMS_OUTPUT.PUT_LINE(RPAD('Pubid', 20)
							||'Appear in '|| RPAD(current_publication_category, 15)
							||RPAD('Start Page', 15)
							||RPAD('End Page', 15)
							||RPAD('Title', 70));
		FOR v_merged_publication IN cursor_merged_publication LOOP
			--Display the details of the articles together with its category
			IF v_merged_publication.detail_1 = pubid AND v_merged_publication.type = 'Article' THEN
				DBMS_OUTPUT.PUT_LINE(RPAD(v_merged_publication.pubid, 20)
									||RPAD(v_merged_publication.detail_1, 25)
									||RPAD(v_merged_publication.detail_2, 15)
									||RPAD(v_merged_publication.detail_3, 15)
									||RPAD(v_merged_publication.title, 70));
			END IF;
		END LOOP;
	END;--END of procedure
	
BEGIN
	--Process the dataset using cursor to search for publication id, set the boolean variable publication_isExist
	--to true if exist otherwise set to false
	FOR v_merged_publication IN cursor_merged_publication LOOP
		IF v_merged_publication.pubid = pubid THEN
			publication_category := v_merged_publication.type;
			publication_isExist := true;
		END IF;
	END LOOP; 
	--display the articles details if publication exist otherwise raise the exception to indicate that 
	--the article does not exist
	IF publication_isExist THEN
		FOR v_merged_publication IN cursor_merged_publication LOOP
			--set the boolean publication_isExist to false 
			publication_isExist := false;
			--print the details if publication id is matched and the publication is article
			IF v_merged_publication.detail_1 = pubid AND v_merged_publication.type = 'Article' THEN
				displayArticle(publication_category);
				publication_isExist := true;
			END IF;
			--stop when the article id is not exist
			EXIT WHEN publication_isExist = true;
		END LOOP;
	ELSE
		--otherwise raise the exception
		RAISE_APPLICATION_ERROR(-20001, 'Publication not found!');
	END IF;

EXCEPTION
	WHEN publication_not_found THEN
		DBMS_OUTPUT.PUT_LINE(pubid || ' do not exist!');
		DBMS_OUTPUT.PUT_LINE('Error!' || SQLERRM);
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error!' || SQLERRM);
		ROLLBACK;
END;
/