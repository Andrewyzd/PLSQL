CREATE OR REPLACE PROCEDURE print_publication(author_name IN VARCHAR2) AS
	
	TYPE authorList IS RECORD(v_id wrote.aid%TYPE,
							  v_name author.name%TYPE,
							  v_pubid wrote.pubid%TYPE,
							  v_title publication.title%TYPE,
							  v_year journal.year%TYPE);
	--Declare virtual table 			  
	TYPE authorList_table IS TABLE OF authorList INDEX BY PLS_INTEGER;
	--Cursor declaration using author table
	CURSOR cursor_author IS
		SELECT * FROM author;
	--Cursor declaration using publication table
	CURSOR cursor_publication IS
		SELECT * FROM publication;
	--Cursor declaration using wrote table
	CURSOR cursor_wrote IS
		SELECT * FROM wrote;
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
	
	v_author_name cursor_author%ROWTYPE;
	v_wrote cursor_wrote%ROWTYPE;
	v_publication cursor_publication%ROWTYPE;
	v_proceedings cursor_proceedings%ROWTYPE;
	v_journal cursor_journal%ROWTYPE;
	v_book cursor_book%ROWTYPE;
	v_article cursor_article%ROWTYPE;
	--number variable declaration
	v_author_id NUMBER;
	--char variable declaration
	v_publication_id CHAR(10);
	--integer variable declaration
	count_index INTEGER := 0;
	count_end_index INTEGER := 0;
	proceedings_count INTEGER := 0;
	journal_count INTEGER := 0;
	book_count INTEGER := 0;
	article_count INTEGER := 0;
	publication_count INTEGER := 0;
	--boolean variable declaration
	v_AuthorIsExist BOOLEAN := false;
	needSorted BOOLEAN := false;
	needDisplay BOOLEAN := false;
	--assign virtual table into the variable 
	v_authorList authorList_table;
	--exception declaration
	exception_author_not_found EXCEPTION;
	PRAGMA EXCEPTION_INIT(exception_author_not_found, -20001);
	
	--Function to extract all the author that associate with the publication of the selected author
	FUNCTION authorIDwithPublication(pubid CHAR, count_index INTEGER) RETURN INTEGER AS
			--Cursor declaration using wrote table
			CURSOR cursor_wrote IS SELECT * FROM wrote;
			v_wrote cursor_wrote%ROWTYPE;
			--declare integer to count the row position
			v_index INTEGER := count_index;
	BEGIN
		--use for loop to process the dataset in cursor that are from wrote table  
		FOR v_wrote IN cursor_wrote LOOP
			--transfer the author id and publication id to virtual table if the publication id is the same 
			IF(v_wrote.pubid = pubid) THEN
				v_authorList(v_index).v_id := v_wrote.aid;
				v_authorList(v_index).v_pubid := v_wrote.pubid;
				--move to the next row
				v_index := v_index + 1;
			END IF;
		END LOOP;
		--return the current row position
		RETURN v_index;
	END;--END of function
	
	--Procedure to sort the data by name using insertion sort
	PROCEDURE sortDataByName(start_index INTEGER, end_index INTEGER) AS
		--declare the variable to indicate which row in the virtual table to start with
		startAt INTEGER := start_index;
		--declare the variable to indicate the next row of the starting row
		startAt_increase INTEGER := start_index + 1;
		--declare the last row to indicate which row in the virtual table to stop at
		endAt INTEGER := end_index;
		--declare the variable to store the dataset
		current_name_index INTEGER;
		current_author_id NUMBER;
		current_name author.name%TYPE;
	BEGIN
		FOR I IN startAt_increase .. endAt LOOP
			--assign the current author id, current author name, and current row position in the virtual table
			current_author_id := v_authorList(I).v_id;
			current_name := v_authorList(I).v_name;
			current_name_index := I;
			--execute the while when the current row position is greater than the starting row 
			--and the author name of the current row is smaller than the previous row  
			WHILE((current_name_index > startAt) AND (current_name < v_authorList(current_name_index - 1).v_name))LOOP
				--exchange the dataset between two rows  
				v_authorList(current_name_index).v_id := v_authorList(current_name_index - 1).v_id;
				v_authorList(current_name_index).v_name := v_authorList(current_name_index - 1).v_name;
				current_name_index := current_name_index - 1;
				v_authorList(current_name_index).v_id := current_author_id;
				v_authorList(current_name_index).v_name := current_name;
			END LOOP;
		END LOOP;
	END;--END of procedure
	
	--Procedure to sort the data by year using insertion sort
	PROCEDURE sortDataByYear AS
		--declare the variable to indicate which row in the virtual table to start with
		startAt INTEGER := v_authorList.FIRST;
		--declare the variable to indicate the next row of the starting row
		startAt_increase INTEGER := startAt + 1;
		--declare the variable to store the dataset
		current_year_index INTEGER;
		current_author_id author.aid%TYPE;
		current_name author.name%TYPE;
		current_pubid wrote.pubid%TYPE;
		current_year journal.year%TYPE;
	BEGIN
		FOR I IN startAt_increase .. v_authorList.LAST LOOP
			current_author_id := v_authorList(I).v_id;
			current_name := v_authorList(I).v_name;
			current_pubid := v_authorList(I).v_pubid;
			current_year := v_authorList(I).v_year;
			current_year_index := I;
			--execute the while when the current row position is greater than the starting row 
			--and the year of the current row is smaller than the previous row 			
			WHILE((current_year_index > startAt) AND (current_year < v_authorList(current_year_index - 1).v_year))LOOP
				v_authorList(current_year_index).v_id := v_authorList(current_year_index - 1).v_id;
				v_authorList(current_year_index).v_name := v_authorList(current_year_index - 1).v_name;
				v_authorList(current_year_index).v_pubid := v_authorList(current_year_index - 1).v_pubid;
				v_authorList(current_year_index).v_year := v_authorList(current_year_index - 1).v_year;
				current_year_index := current_year_index - 1;
				v_authorList(current_year_index).v_id := current_author_id;
				v_authorList(current_year_index).v_name := current_name;
				v_authorList(current_year_index).v_pubid := current_pubid;
				v_authorList(current_year_index).v_year := current_year;
			END LOOP;		
		END LOOP;
	END;--END of procedure
	
	--Function to display all the names of the author based on publication
	FUNCTION DisplayAuthor(v_publication_id IN VARCHAR) RETURN INTEGER AS
		--variable declaration to store the dataset
		current_publication wrote.pubid%TYPE := v_publication_id;
		current_count_index INTEGER := 0;
	BEGIN
		DBMS_OUTPUT.PUT('Author: ');
		--for loop to process the data in the virtual table
		FOR count_index IN v_authorList.FIRST .. v_authorList.LAST LOOP
			--display the name of the author if the same publication id is detected
			IF v_authorList(count_index).v_pubid = current_publication THEN
				DBMS_OUTPUT.PUT(v_authorList(count_index).v_name || ', ');
				--assign the current row position to the current_count_index variable 
				current_count_index := count_index;
			ELSE
				--otherwise fix with the previous row
				current_count_index := current_count_index;
			END IF;
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('');
		--return the current row position where is the another publication from the selected author
		RETURN current_count_index;
	END;--END of function
	
BEGIN
	-- Looping to check whether the author exist or not
	IF NOT cursor_author%ISOPEN THEN
		--Open the cursor
		OPEN cursor_author;
	END IF;
	
	LOOP
		--Fetch the record to variable
		FETCH cursor_author INTO v_author_name;
		--set the v_AuthorIsExist variable to true if the author exist 
		IF(UPPER(v_author_name.name) = UPPER(author_name)) THEN
			v_author_id := v_author_name.aid;
			v_AuthorIsExist := true;
		END IF;
		--Stop the loop when no more record are found
		EXIT WHEN cursor_author%NOTFOUND;		
	END LOOP;
	--Raise error when the author does not exist
	IF(v_AuthorIsExist = false) THEN
		RAISE_APPLICATION_ERROR(-20001, 'The author does not exist !');
	END IF;
	--Close the cursor
	CLOSE cursor_author;	
	
	--loop to extract all the publication of the author
	FOR v_wrote IN cursor_wrote LOOP
		IF(v_wrote.aid = v_author_id) THEN
			count_index := authorIDwithPublication(v_wrote.pubid, count_index);
		END IF;
	END LOOP;	
	
	--loop to extract all the name of the author that publish the same publication with selected author
	FOR count_index IN v_authorList.FIRST .. v_authorList.LAST LOOP
		FOR v_author_name IN cursor_author LOOP
			IF (v_author_name.aid = v_authorList(count_index).v_id) THEN
				v_authorList(count_index).v_name := v_author_name.name;
			END IF;
		END LOOP;
	END LOOP;
	
	--loop to extract all the name of authors that are under a same publication
	FOR count_index IN v_authorList.FIRST .. v_authorList.LAST LOOP
		v_publication_id := v_authorList(count_index).v_pubid;
		
		WHILE (count_end_index + 1 <= v_authorList.LAST AND v_authorList(count_end_index).v_pubid = v_publication_id) LOOP
			--set needSorted variable to true to sort the names of the authors
			needSorted := true;
			--move to the next row in the virtual table
			count_end_index := count_end_index + 1;
		END LOOP;
		--if it is true, sort the dataset in the virtual table according to name
		IF needSorted THEN
			sortDataByName(count_index, count_end_index - 1);
			publication_count := publication_count + 1;
			needSorted := false;
		END IF;
	END LOOP;
	
	--loop to extract the year of the book publication
	FOR v_book IN cursor_book LOOP	
		FOR count_index IN v_authorList.FIRST .. v_authorList.LAST LOOP
			--if the publication is book
			IF v_authorList(count_index).v_pubid = v_book.pubid THEN
				--transfer the publication year of the book to the virtual table 
				v_authorList(count_index).v_year := v_book.year;
			END IF;
		END LOOP;
	END LOOP;
	
	--loop to extract the year of the proceedings publication
	FOR v_proceedings IN cursor_proceedings LOOP	
		FOR count_index IN v_authorList.FIRST .. v_authorList.LAST LOOP
			--if the publication is proceedings
			IF v_authorList(count_index).v_pubid = v_proceedings.pubid THEN
				--transfer the publication year of the proceedings to the virtual table 
				v_authorList(count_index).v_year := v_proceedings.year;
			END IF;
		END LOOP;
	END LOOP;
	
	--loop to extract the year of the journal publication
	FOR v_journal IN cursor_journal LOOP	
		FOR count_index IN v_authorList.FIRST .. v_authorList.LAST LOOP
			--if the publication is journal
			IF v_authorList(count_index).v_pubid = v_journal.pubid THEN
				--transfer the publication year of the journal to the virtual table 
				v_authorList(count_index).v_year := v_journal.year;
			END IF;
		END LOOP;
	END LOOP;
	
	--loop to extract the year of the article publication
	FOR v_article IN cursor_article LOOP
		FOR count_index IN v_authorList.FIRST .. v_authorList.LAST LOOP
			--if the publication is article
			IF v_authorList(count_index).v_pubid = v_article.pubid THEN
				FOR v_journal IN cursor_journal LOOP
					--if the article appear in journal
					IF v_article.appearsin = v_journal.pubid THEN
						--transfer the publication year of the journal to the virtual table 
						v_authorList(count_index).v_year := v_journal.year;
					END IF;
				END LOOP;
				FOR v_proceedings IN cursor_proceedings LOOP
					-- if the article appear in proceedings
					IF v_article.appearsin = v_proceedings.pubid THEN
						--transfer the publication year of the proceedings to the virtual table 
						v_authorList(count_index).v_year := v_proceedings.year;
					END IF;
				END LOOP;	
			END IF;
		END LOOP;
	END LOOP;
	
	--sort the dataset in the virtual table by year
	sortDataByYear;
	
	--loop to extract all the title of the publication by author 
	FOR count_index IN v_authorList.FIRST .. v_authorList.LAST LOOP
		FOR v_publication IN cursor_publication LOOP
			IF (v_publication.pubid = v_authorList(count_index).v_pubid) THEN
				v_authorList(count_index).v_title := v_publication.title;
			END IF;
		END LOOP;
	END LOOP;
	
	--Display the details of each publication
	count_index := 0;
	FOR I IN 0 .. publication_count LOOP
		WHILE count_index <= v_authorList.LAST LOOP
			v_publication_id := v_authorList(count_index).v_pubid;
			FOR v_book IN cursor_book LOOP
			--Display the details of book if any
				IF v_publication_id = v_book.pubid THEN
					book_count := book_count + 1;
					DBMS_OUTPUT.PUT_LINE('Pubid: ' || v_authorList(count_index).v_pubid);
					DBMS_OUTPUT.PUT_LINE('Type: {Book}');
					count_index := DisplayAuthor(v_publication_id);
					DBMS_OUTPUT.PUT_LINE('Title: ' || v_authorList(count_index).v_title);
					DBMS_OUTPUT.PUT_LINE('Publisher: ' || v_book.publisher);
					DBMS_OUTPUT.PUT_LINE('Year: ' || v_authorList(count_index).v_year);
					needDisplay := false;
					count_index := count_index + 1;
				END IF;
				--stop the loop when all the details of a publication are displayed 
				EXIT WHEN needDisplay = false;
			END LOOP;
			--Display the details of proceedings if any
			FOR v_proceedings IN cursor_proceedings LOOP
				IF v_publication_id = v_proceedings.pubid THEN
					proceedings_count := proceedings_count + 1;
					DBMS_OUTPUT.PUT_LINE('Pubid: ' || v_authorList(count_index).v_pubid);
					DBMS_OUTPUT.PUT_LINE('Type: {Proceedings}');
					count_index := DisplayAuthor(v_publication_id);
					DBMS_OUTPUT.PUT_LINE('Title: ' || v_authorList(count_index).v_title);
					DBMS_OUTPUT.PUT_LINE('Year: ' || v_authorList(count_index).v_year);
					needDisplay := false;
					count_index := count_index + 1;
				END IF;
				--stop the loop when all the details of a publication are displayed 
				EXIT WHEN needDisplay = false;
			END LOOP;
			--Display the details of journal if any
			FOR v_journal IN cursor_journal LOOP
				IF v_publication_id = v_journal.pubid THEN
					journal_count := journal_count + 1;
					DBMS_OUTPUT.PUT_LINE('Pubid: ' || v_authorList(count_index).v_pubid);
					DBMS_OUTPUT.PUT_LINE('Type: {Journal}');
					count_index := DisplayAuthor(v_publication_id);
					DBMS_OUTPUT.PUT_LINE('Title: ' || v_authorList(count_index).v_title);
					DBMS_OUTPUT.PUT_LINE('Volume: ' || v_journal.volume);
					DBMS_OUTPUT.PUT_LINE('Number: ' || v_journal.num);
					DBMS_OUTPUT.PUT_LINE('Year: ' || v_authorList(count_index).v_year);
					needDisplay := false;
					count_index := count_index + 1;
				END IF;
				--stop the loop when all the details of a publication are displayed 
				EXIT WHEN needDisplay = false;
			END LOOP;
			
			FOR v_article IN cursor_article LOOP
			--Display the details of article if any
				IF v_publication_id = v_article.pubid THEN
					article_count := article_count + 1; 
					--Display the details of article if it is under proceedings category
					FOR v_proceedings IN cursor_proceedings LOOP
						IF v_article.appearsin = v_proceedings.pubid THEN
							DBMS_OUTPUT.PUT_LINE('Pubid: ' || v_authorList(count_index).v_pubid);
							DBMS_OUTPUT.PUT_LINE('Type: {Article}');
							count_index := DisplayAuthor(v_publication_id);
							DBMS_OUTPUT.PUT_LINE('Title: ' || v_authorList(count_index).v_title);
							DBMS_OUTPUT.PUT_LINE('Appear in proceedings: ' || v_article.appearsin);
							DBMS_OUTPUT.PUT_LINE('Start Page: ' || v_article.startpage);
							DBMS_OUTPUT.PUT_LINE('End Page: '|| v_article.endpage);
							DBMS_OUTPUT.PUT_LINE('Year: ' || v_authorList(count_index).v_year);
							needDisplay := false;
							count_index := count_index + 1;
						END IF;
						--stop the loop when all the details of a publication are displayed 
						EXIT WHEN needDisplay = false;
					END LOOP;				
					--Display the details of article if it is under journal category
					FOR v_journal IN cursor_journal LOOP
						IF v_article.appearsin = v_journal.pubid THEN
							DBMS_OUTPUT.PUT_LINE('Pubid: ' || v_authorList(count_index).v_pubid);
							DBMS_OUTPUT.PUT_LINE('Type: {Article}');
							count_index := DisplayAuthor(v_publication_id);
							DBMS_OUTPUT.PUT_LINE('Title: ' || v_authorList(count_index).v_title);
							DBMS_OUTPUT.PUT_LINE('Appear in journal: ' || v_article.appearsin);
							DBMS_OUTPUT.PUT_LINE('Volume: ' || v_journal.volume);
							DBMS_OUTPUT.PUT_LINE('Number: ' || v_journal.num);
							DBMS_OUTPUT.PUT_LINE('Start Page: ' || v_article.startpage);
							DBMS_OUTPUT.PUT_LINE('End Page: '|| v_article.endpage);
							DBMS_OUTPUT.PUT_LINE('Year: ' || v_authorList(count_index).v_year);
							needDisplay := false;
							count_index := count_index + 1;
						END IF;
					--stop the loop when all the details of a publication are displayed 
					EXIT WHEN needDisplay = false;
					END LOOP;
				END IF;
			--stop the loop when all the details of a publication are displayed 
			EXIT WHEN needDisplay = false;
			END LOOP;
			--stop the loop when all the details of a publication are displayed 
			EXIT WHEN needDisplay = false;
		END LOOP;
		needDisplay := true;
		DBMS_OUTPUT.PUT_LINE('================================');
	END LOOP;	
	--Display the summary of the total publication
	DBMS_OUTPUT.PUT_LINE('Summary of publication: ');
	DBMS_OUTPUT.PUT_LINE('Proceedings : ' || proceedings_count);
	DBMS_OUTPUT.PUT_LINE('Journal : ' || journal_count);
	DBMS_OUTPUT.PUT_LINE('Article : ' || article_count);
	DBMS_OUTPUT.PUT_LINE('Book : '|| book_count);
	DBMS_OUTPUT.PUT_LINE('Total Publication : ' || publication_count);
	
EXCEPTION
	WHEN exception_author_not_found THEN
		DBMS_OUTPUT.PUT_LINE('Error: '|| SQLERRM);
		
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
		ROLLBACK;
END;
/