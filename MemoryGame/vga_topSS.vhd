MemoryGameRESET : PROCESS (clk_in, reset) -- state machine clock process
		BEGIN
			IF (btn_center = '1' and btn_left = '1' and btn_right = '1') THEN -- reset to known state
				current_state <= IDLE;
				--current_state <= ENTER_ACC;?
			ELSIF rising_edge (clk_in) THEN -- on rising clock edge
			    current_state <= next_state;
			END IF;
		END PROCESS;
		-- state maching combinatorial process
		-- determines output of state machine and next state
		MemoryGameLogic: PROCESS --(failed, btn_center, btn_up, btn_down, btn_left, btn_right, color_chosen_FSM, arrow_direction_FSM, MANUAL, game_len, game_index, user_index)
		BEGIN
		wait until rising_edge(clk_in);            
			CASE current_state IS -- depending on present state...
				WHEN IDLE => -- waiting for next digit in 1st operand entry
                        if btn_center = '1' then
                        --counter <= 0;
                        game_len <= 5;    --default 0+1 (Game length is current level array length for user to match)
                        game_index <= 0;  --default            (Game Index is game_length - 1 after idle allows for extrapolating each iteration of array length as single value)
                        --user_len <= 0;    --default            (User index handles user inputs up until less than game length, user index 19 is game length 20 or game index 19. Therefore)
                        user_index <= 0;   --default             (User index must be less than game length - 1, Cannot be less than game index as game index should reset to avoid issues)
                        failed <= 0;
			             next_state <= GAME_OUTPUT_PRESS;
                        end if;
                        color_chosen_FSM <= 0;
				WHEN GAME_OUTPUT_PRESS => -- waiting for center button to be pressed
				    if btn_center = '1' then
				    arrow_direction_FSM <= manual(game_index);--Manual(0)
				    game_index <= game_index + 1;
				    --Show first thingy
				    -- arrow should equal first array(index 0)
				    next_state <= GAME_OUTPUT_RELEASE; -- On press wait for releast
				    else
				    arrow_direction_FSM <= 5; -- On release go to press 
				    next_state <= GAME_OUTPUT_PRESS; -- No press stay here
                    end if;
                    
				WHEN GAME_OUTPUT_RELEASE => -- waiting for center button to be released
                    if (btn_center = '0') and (game_index < game_len) then -- if button released, and more arrows yet to be displayed, goto GAME_OUTPUT_RELEASE
                    next_state <= GAME_OUTPUT_PRESS;
                    --counter <= 0;
                    elsif (btn_center = '0') and (game_index >= game_len) then -- if button is released, all arrows have been displayed sucessfully, goto USER_INPUT_PRESS
                    --counter <= 0;
                    game_index <= 0; -- RESET GAME INDEX TO COMPARE TO USER INDEX
                    next_state <= USER_INPUT_PRESS;
                    else -- IF BUTTON NOT RELEASED YET, STAY HERE UNTIL IT IS
                    next_state <= GAME_OUTPUT_RELEASE;
                    end if;
				WHEN USER_INPUT_PRESS => -- waiting for button ot be released
                    if (btn_up = '1' OR btn_down = '1' OR btn_left = '1' OR btn_right = '1') THEN
                            if (btn_up = '1' and manual(game_index) = 1) or
                               (btn_down = '1' and manual(game_index) = 2) or
                               (btn_left = '1' and manual(game_index) = 3) or
                               (btn_right = '1' and manual(game_index) = 4) then
                               color_chosen_FSM <= 2; --GREEN IS GOOD
                               arrow_direction_FSM <= manual(game_index); -- CAN USE THIS VALUE BECAUSE WE KNOW WE WERE CORRECT
                               
                            else
                               color_chosen_FSM <= 1;
                               arrow_direction_FSM <= manual(game_index); -- simply show the correct arrow, but in red    
                               failed <= 1; -- Necessary to keep wrong red arrow on screen long enough before releasing to enter 
                            end if;
                            user_index <= user_index + 1; --Increments both user and game indicies
                            game_index <= game_index + 1; --user and game index should always equal each other anyways
                            next_state <= USER_INPUT_RELEASE;
                             
                    else
                    arrow_direction_FSM <= 5;
                    next_state <= USER_INPUT_PRESS;
                    end if;
                    -- Display arrow while user input
                    -- must increment user length
                    -- go until user length reaches game length
                    -- CHECK FIRST IF RIGHT, DISPLAY GREEN IF RIGHT RED IF WRONG                
                    
				WHEN USER_INPUT_RELEASE => -- waiting for next digit in 2nd operand
                    -- STOP SHOWING ARROW, OTHER INCREMENT B
                    if (failed = 1) THEN -- YOU FAILED GAME RESET
                    arrow_direction_FSM <= 5;
                    next_state <= IDLE;
                    elsif (user_index < game_len) THEN -- On release and still need more iterations
                    arrow_direction_FSM <= 5;
                    next_state <= USER_INPUT_PRESS;
                    elsif (user_index >= game_len) THEN -- On release and finished current level stage
                    game_len <= game_len + 1;
                    arrow_direction_FSM <= 5;
                    next_state <= GAME_OUTPUT_PRESS;
                    end if;
                    else
                    next_state <= USER_INPUT_RELEASE;
                    end if;
                END CASE;
			
		END PROCESS;

