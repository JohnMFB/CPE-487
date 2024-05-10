LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY hexcalc IS
	PORT (
		clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
		SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of eight 7-seg displays
		SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
        btn_center : IN STD_LOGIC; -- Start game
        btn_up : IN STD_LOGIC; -- User input for up arrow
        btn_left : IN STD_LOGIC; -- User input for left arrow
        btn_right : IN STD_LOGIC; -- User input for right arrow
        btn_down : IN STD_LOGIC -- User input for down arrow
        );
END hexcalc;

ARCHITECTURE Behavioral OF hexcalc IS

	COMPONENT leddec16 IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
    SIGNAL game_sequence : std_logic_vector(15 DOWNTO 0) := X"1234"; -- Example game sequence
    SIGNAL user_sequence : std_logic_vector(15 DOWNTO 0) := (others => '0');
	SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
	SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
	TYPE state_type IS (IDLE, DISPLAY_SEQ, USER_INPUT, CHECK_INPUT, SHOW_RESULT);
	SIGNAL next_state, current_state : state_type := IDLE; -- present and next states
	SIGNAL seq_index : integer range 0 to 3 := 0;
		SIGNAL cnt : std_logic_vector(20 DOWNTO 0); -- counter to generate timing signals
	
BEGIN

	Clock : PROCESS (clk_50MHz)--display and timing
	BEGIN
		IF rising_edge(clk_50MHz) THEN -- on rising edge of clock
			cnt <= cnt + 1; -- increment counter
		END IF;
	END PROCESS;
	
	led_mpx <= cnt(19 DOWNTO 17); -- 7-seg multiplexing clock
	
    led1 : leddec16
    PORT MAP(
        dig => led_mpx, data => display, 
        anode => SEG7_anode, seg => SEG7_seg
    );
    FSM_Clock : PROCESS
    BEGIN
    WAIT UNTIL rising_edge(clk_50MHz);
    current_state <= next_state;
    END PROCESS;
		MEMORYGAMEFSM : PROCESS -- state machine clock process
		BEGIN
		    wait until rising_edge(clk_50MHz);
			
			
			CASE current_state IS -- depending on present state...
				WHEN IDLE => -- waiting for next digit in 1st operand entry
					IF btn_center = '1' THEN
					   next_state <= DISPLAY_SEQ;
					   seq_index <= 0;
					   display <= '0000000000000000';
					ELSE
					   next_state <= IDLE;
					END IF;					
				WHEN DISPLAY_SEQ => -- waiting for button to be released
					display <= game_sequence;
					IF seq_index < 4 THEN
					   seq_index <= seq_index + 1;
					ELSE
					   next_state <= USER_INPUT;
					   seq_index <= 0;
					END IF;
				WHEN USER_INPUT => -- ready to start entering 2nd operand
		             IF btn_up = '1' OR btn_down = '1' OR btn_left = '1' OR btn_right = '1' THEN
                        user_sequence(seq_index * 4 + 3 DOWNTO seq_index * 4) <= "1111"; -- Example input
                        seq_index <= seq_index + 1;
                        IF seq_index >= 4 THEN
                            next_state <= CHECK_INPUT;
                        END IF;
                    END IF;
                WHEN CHECK_INPUT =>
                    IF user_sequence = game_sequence THEN
                        -- Set display to show all 1s
                        display <= "0110000011000000";  -- Display "11" on part of the display (assuming 8 bits for simplicity)
                    ELSE
                        -- Set display to show all Fs
                        display <= "1001111100111110";  -- Display "FF" on part of the display (assuming 8 bits for simplicity)
                    END IF;
                    next_state <= SHOW_RESULT;
                
  
				WHEN SHOW_RESULT => -- waiting for next digit in 2nd operand
                    IF btn_center = '1' THEN
                        next_state <= IDLE;
                    ELSE
                        next_state <= SHOW_RESULT;
                    END IF;
                WHEN OTHERS =>
                    next_state <= IDLE;
			END CASE;
			
		END PROCESS;
END Behavioral;
