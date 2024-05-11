--Drop the table publication_master if exist
DROP TABLE publication_master CASCADE CONSTRAINTS purge;

--Create the table publication_master
CREATE TABLE publication_master(
	pubid CHAR(20) NOT NULL,
	title CHAR(70) NOT NULL,
	detail_1 CHAR(50),
	detail_2 CHAR(15),
	detail_3 CHAR(15),
	type CHAR(12) NOT NULL,
	PRIMARY KEY (pubid));
	
CREATE OR REPLACE PROCEDURE merge_publication AS
	--Cursor declaration using publication table
	CURSOR cursor_publication IS
		SELECT * FROM publication;
	--Cursor declaration using proceedings table
	CURSOR cursor_proceedings IS
		SELECT * FROM proceedings;
	--Cursor declaration using journal table
	CURSOR cursor_journal IS
		SELECT * FROM journal;
	--Cursor declaration using book table
	CURSOR cursor_book IS
		SELECT * FROM book;
	--Cursor declaration using article table
	CURSOR cursor_article IS
		SELECT * FROM article;
		
	v_publication cursor_publication%ROWTYPE;
	v_proceedings cursor_proceedings%ROWTYPE;
	v_journal cursor_journal%ROWTYPE;
	v_book cursor_book%ROWTYPE;
	v_article cursor_article%ROWTYPE;
	--integer variable declaration to count the number of proceedings publication, 
	--journal publication, book publication, and article publication
	proceedings_count INTEGER := 0;
	journal_count INTEGER := 0;
	book_count INTEGER := 0;
	article_count INTEGER := 0;
	total_insertion_count INTEGER;
	
	PROCEDURE printPublication AS
		--Cursor declaration for proceedings publication
		CURSOR cursor_TypeProceedings IS 
			SELECT * FROM publication_master WHERE publication_master.type = 'Proceedings'; 
		--Cursor declaration for journal publication
		CURSOR cursor_TypeJournal IS 
			SELECT * FROM publication_master WHERE publication_master.type = 'Journal';
		--Cursor declaration for book publication
		CURSOR cursor_TypeBook IS 
			SELECT * FROM publication_master WHERE publication_master.type = 'Book';
		--Cursor declaration for article publication
		CURSOR cursor_TypeArticle IS 
			SELECT * FROM publication_master WHERE publication_master.type = 'Article';
		
		v_TypeProceedings cursor_TypeProceedings%ROWTYPE;
		v_TypeJournal cursor_TypeJournal%ROWTYPE;
		v_TypeBook cursor_TypeBook%ROWTYPE;
		v_TypeArticle cursor_TypeArticle%ROWTYPE;
		
	BEGIN
		--display the book publication details if any
		IF book_count <> 0 THEN
			--Display the appropriate column name based on Book details
			DBMS_OUTPUT.PUT_LINE(RPAD('Pubid', 20)
								||RPAD('Publisher', 15)
								||RPAD('Year', 15)
								||RPAD('Title', 70)
								||RPAD('Type', 15));
			FOR v_TypeBook IN cursor_TypeBook LOOP
				DBMS_OUTPUT.PUT_LINE(RPAD(v_TypeBook.pubid, 20)
									||RPAD(v_TypeBook.detail_1, 15)
									||RPAD(v_TypeBook.detail_3, 15)
									||RPAD(v_TypeBook.title, 70)
									||RPAD(v_TypeBook.type, 15));
			END LOOP;
			DBMS_OUTPUT.PUT_LINE('/');
		END IF;
		--display the proceedings publication details if any
		IF proceedings_count <> 0 THEN
			--Display the appropriate column name based on Proceedings details
			DBMS_OUTPUT.PUT_LINE(RPAD('Pubid', 20)
								||RPAD('Year', 15)
								||RPAD('Title', 70)
								||RPAD('Type', 15));
			FOR v_TypeProceedings IN cursor_TypeProceedings LOOP
				DBMS_OUTPUT.PUT_LINE(RPAD(v_TypeProceedings.pubid, 20)
									||RPAD(v_TypeProceedings.detail_3, 15)
									||RPAD(v_TypeProceedings.title, 70)
									||RPAD(v_TypeProceedings.type, 15));
			END LOOP;
			DBMS_OUTPUT.PUT_LINE('/');
		END IF;
		--display the journal publication details if any
		IF journal_count <> 0 THEN
			--Display the appropriate column name based on Journal details
			DBMS_OUTPUT.PUT_LINE(RPAD('Pubid', 20)
								||RPAD('Volume', 15)
								||RPAD('Number', 15)
								||RPAD('Year', 15)
								||RPAD('Title', 70)
								||RPAD('Type', 15));
			FOR v_TypeJournal IN cursor_TypeJournal LOOP
				DBMS_OUTPUT.PUT_LINE(RPAD(v_TypeJournal.pubid, 20)
									||RPAD(v_TypeJournal.detail_1, 15)
									||RPAD(v_TypeJournal.detail_2, 15)
									||RPAD(v_TypeJournal.detail_3, 15)
									||RPAD(v_TypeJournal.title, 70)
									||RPAD(v_TypeJournal.type, 15));
			END LOOP;
			DBMS_OUTPUT.PUT_LINE('/');
		END IF;
		--display the article publication details if any
		IF article_count <> 0 THEN
			--Display the appropriate column name based on Article details
			DBMS_OUTPUT.PUT_LINE(RPAD('Pubid', 20)
								||RPAD('Appear in', 15)
								||RPAD('Start Page', 15)
								||RPAD('End Page', 15)
								||RPAD('Title', 70)
								||RPAD('Type', 15));
			FOR v_TypeArticle IN cursor_TypeArticle LOOP
				DBMS_OUTPUT.PUT_LINE(RPAD(v_TypeArticle.pubid, 20)
									||RPAD(v_TypeArticle.detail_1, 15)
									||RPAD(v_TypeArticle.detail_2, 15)
									||RPAD(v_TypeArticle.detail_3, 15)
									||RPAD(v_TypeArticle.title, 70)
									||RPAD(v_TypeArticle.type, 15));
			END LOOP;
			DBMS_OUTPUT.PUT_LINE('/');
		END IF;
	END;
	
BEGIN
	
	FOR v_publication IN cursor_publication LOOP
		--transfer the details of proceedings to publication_master table if any
		FOR v_proceedings IN cursor_proceedings LOOP
			IF v_publication.pubid = v_proceedings.pubid THEN
				INSERT INTO publication_master(pubid, title, detail_3, type) 
					VALUES(v_publication.pubid, v_publication.title,TO_CHAR(v_proceedings.year), 'Proceedings');
				proceedings_count := proceedings_count + 1;
			END IF;
		END LOOP;
		--transfer the details of journal to publication_master table if any
		FOR v_journal IN cursor_journal LOOP
			IF v_publication.pubid = v_journal.pubid THEN
				INSERT INTO publication_master(pubid, title, detail_1, detail_2,detail_3, type) 
					VALUES(v_publication.pubid, v_publication.title, TO_CHAR(v_journal.volume), TO_CHAR(v_journal.num), TO_CHAR(v_journal.year), 'Journal');
				journal_count := journal_count + 1;
			END IF;
		END LOOP;
		--transfer the details of book to publication_master table if any
		FOR v_book IN cursor_book LOOP
			IF v_publication.pubid = v_book.pubid THEN
				INSERT INTO publication_master(pubid, title, detail_1,detail_3, type) 
					VALUES(v_publication.pubid, v_publication.title, TO_CHAR(v_book.publisher), TO_CHAR(v_book.year), 'Book');
				book_count := book_count + 1;
			END IF;			
		END LOOP;
		--transfer the details of article to publication_master table if any
		FOR v_article IN cursor_article LOOP
			IF v_publication.pubid = v_article.pubid THEN
				INSERT INTO publication_master(pubid, title, detail_1,detail_2,detail_3, type) 
					VALUES(v_publication.pubid, v_publication.title, TO_CHAR(v_article.appearsin), TO_CHAR(v_article.startpage), TO_CHAR(v_article.endpage), 'Article');
				article_count := article_count + 1;
			END IF;
		END LOOP;
	END LOOP;
	
	--Display the error messages if and only if there are no any details are found in
	--proceedings table, journal table, book table, and article table respectively.
	--Display error messages when no details are found in proceedings table
	IF proceedings_count = 0 THEN
		DBMS_OUTPUT.PUT_LINE('No details found in proceedings table.');
	END IF;
	--Display error messages when no details are found in journal table
	IF journal_count = 0 THEN
		DBMS_OUTPUT.PUT_LINE('No details found in journal table.');
	END IF;
	--Display error messages when no details are found in book table
	IF book_count = 0 THEN
		DBMS_OUTPUT.PUT_LINE('No detail found in book table.');
	END IF;
	--Display error messages when no details are found in article table
	IF article_count = 0 THEN
		DBMS_OUTPUT.PUT_LINE('No detail found in article table.');
	END IF;
	--Display the total publications that is successfully insert into the publication_master table
	total_insertion_count := (proceedings_count + journal_count + book_count + article_count);
	DBMS_OUTPUT.PUT_LINE(total_insertion_count || ' of publication have been successfully posted!');
	DBMS_OUTPUT.PUT_LINE('/');
	--Display all the publication with different type accordingly
	printPublication;
	
	COMMIT;--save the record permenantly
	
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
		ROLLBACK;
END;
/