LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY vga_top IS
    PORT (
        clk_in    : IN STD_LOGIC;
        vga_red   : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --VGA_TOP will be main game governing code
        vga_green : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- Must add stuff for the game's access to drawing arrows for pattern part of FSM
        vga_blue  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        vga_hsync : OUT STD_LOGIC;
        vga_vsync : OUT STD_LOGIC;
        clk       : IN  STD_LOGIC;
        reset     : IN  STD_LOGIC; 
        btn_up    : IN  STD_LOGIC;
        btn_down  : IN  STD_LOGIC;
        btn_left  : IN  STD_LOGIC;
        btn_right : IN  STD_LOGIC
    );
END vga_top;

ARCHITECTURE Behavioral OF vga_top IS
    SIGNAL pxl_clk : STD_LOGIC;
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --Will input values for vga_sync's red_in etc.
    SIGNAL S_vsync : STD_LOGIC; --Will input values for vga_sync's vsync_in
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0); -- Same stuff here
    SIGNAL arrow_direction_FSM : INTEGER range 1 to 4; -- Temporary value to input into Arrow portmap's arrow_direction etc.
    TYPE state IS (GAME_OUTPUT, IDLE, SHOW_ARROW, CHECK_INPUT, NEXT_LEVEL); -- State of game
    SIGNAL current_state, next_state : state := IDLE; -- State of game

    -- The good stuff
    SIGNAL rand_reg : std_logic_vector(31 downto 0) := x"12345678";
    SIGNAL random_number : integer range 1 to 4;
    constant MAX_SEQ_LENGTH : integer := 20; -- If you go past this point congrats you broke my game
    type seq_array is array (0 to MAX_SEQ_LENGTH-1) of integer range 1 to 4;
    signal sequence : seq_array := (others => 1);
    signal seq_len : integer := 0;
    signal seq_index : integer := 0;
    signal display_timer : integer := 0;

    COMPONENT Arrow IS
        PORT (
            v_sync      : IN  STD_LOGIC;
            pixel_row   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
            --red         : OUT STD_LOGIC;
            --green       : OUT STD_LOGIC; --red -> s_red not needed anymore
            --blue        : OUT STD_LOGIC; -- done directly from fsm
            arrow_direction : IN INTEGER range 1 to 4 --5th state for no arrow not needed thanks to output_logic
            
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC;
            green_in  : IN STD_LOGIC;
            blue_in   : IN STD_LOGIC;
            red_out   : OUT STD_LOGIC;
            green_out : OUT STD_LOGIC;
            blue_out  : OUT STD_LOGIC;
            hsync     : OUT STD_LOGIC;
            vsync     : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    
    component clk_wiz_0 is
    port (
      clk_in1  : in std_logic;
      clk_out1 : out std_logic
    );
    end component;
      -- ALL COMPONENTS ABOVE THIS POINT
BEGIN --BEGIN 
    vga_red(1 DOWNTO 0) <= "00";
    vga_green(1 DOWNTO 0) <= "00"; --REQUIRED TO MAKE RGB WORK
    vga_blue(0) <= '0'; --VIA HERE UTILIZE S_red, S_green, S_blue
    
    
    -- Pseudo-random number generator process
PRNG: process(pxl_clk, reset)
begin
    if reset = '1' then
        rand_reg <= (others => '0');
    elsif rising_edge(pxl_clk) then
        rand_reg <= rand_reg(30 downto 0) & (rand_reg(31) xor rand_reg(3));
        random_number <= to_integer(unsigned(rand_reg(31 downto 30))) mod 4 + 1;  -- Properly using to_integer and unsigned
    end if;
end process;
    
	--THE GAME FSM LOGIC
    MemoryGameLogic: process(current_state, btn_up, btn_down, btn_left, btn_right)
    begin
        case current_state is
            when IDLE =>
                if (btn_up = '1' or btn_down = '1' or btn_left = '1' or btn_right = '1') and seq_len = 0 then --seq_len set to 0 on fail
                    seq_len <= 1;
                    sequence(0) <= random_number;
                    next_state <= GAME_OUTPUT;
                end if;

            when GAME_OUTPUT =>
                if seq_index < seq_len then
                    if display_timer = 0 then
                        arrow_direction_FSM <= sequence(seq_index);
                        display_timer <= 10;  --Display time for each arrow
                        S_red <= '1'; S_green <= '0'; S_blue <= '0';  -- Display in red
                        seq_index <= seq_index + 1;
                    else
                        display_timer <= display_timer - 1;
                    end if;
                else
                    seq_index <= 0;
                    next_state <= CHECK_INPUT;
                end if;

            when SHOW_ARROW =>
                if display_timer > 0 then
                    display_timer <= display_timer - 1;
                else
                    next_state <= CHECK_INPUT;
                end if;

            when CHECK_INPUT =>
                -- Placeholder for user input handling logic
                -- This will check the input from the user and compare with the sequence
                next_state <= NEXT_LEVEL;

            when NEXT_LEVEL =>
                if seq_len < MAX_SEQ_LENGTH then
                    seq_len <= seq_len + 1;
                    sequence(seq_len - 1) <= random_number; -- Add new random number to sequence
                    next_state <= GAME_OUTPUT;
                else
                    next_state <= IDLE;  -- Handle game completion or reset
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    -- Output logic based on the state
    output_logic: PROCESS (current_state)
    BEGIN
        CASE current_state IS
            WHEN SHOW_ARROW =>
                S_red <= '1';  -- Blue arrow displayed for user
                S_green <= '0';
                S_blue <= '0';
            WHEN OTHERS =>
                S_red <= '0';
                S_green <= '0';
                S_blue <= '0'; -- No arrow drawn
        END CASE;
    END PROCESS;
-- ARROW COMPONENT ACCEPTS INPUTS FROM FSM
    addArrow : Arrow
    PORT MAP(
        arrow_direction => arrow_direction_FSM,
        v_sync    => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col
        --red       => S_red, 
        --green     => S_green, -- changed directly in FSM
        --blue      => S_blue
    );
--VGA COMPONENT ACCEPTS COLOR FROM FSM
    vga_driver : vga_sync
    PORT MAP(
        --instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in    => S_red, 
        green_in  => S_green, 
        blue_in   => S_blue, 
        red_out   => vga_red(2), 
        green_out => vga_green(2), 
        blue_out  => vga_blue(1), 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync     => vga_hsync, 
        vsync     => S_vsync
    );
    vga_vsync <= S_vsync;
    
    
    clk_wiz_0_inst : clk_wiz_0
    PORT MAP (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );

END Behavioral;
