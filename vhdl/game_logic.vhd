--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the game logic for the snake physics etc.
--              
-- 
-- 
-- Dependencies: VRAM
-- 
-- 
-- Assisted by:
--
-- Anthonix
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_logic is
  port(
    clk25         : in  std_logic;
    ext_reset     : in  std_logic;
    WEA_int       : out std_logic;
    EN_int        : out std_logic;
    address_a_int : out unsigned(12 downto 0) := "0000000000000";
    input_a_int   : out unsigned(15 downto 0) := "0000000000000000";
    output_a_int  : in  unsigned(15 downto 0) := "0000000000000000";
    colour        : out unsigned(1 downto 0);
    Direction     : in  unsigned(2 downto 0)
    );
end game_logic;

architecture Behavioral of game_logic is


  signal head_cell                                  : unsigned(12 downto 0)        := to_unsigned(2440, 13);  -- cell 2440
  signal tail_cell                                  : unsigned(12 downto 0)        := to_unsigned(2520, 13);  -- cell 2520 (cell below head cell)
  signal corner_cell                                : unsigned(12 downto 0);
  signal score1_cell                                : unsigned(12 downto 0);
  signal score2_cell                                : unsigned(12 downto 0);
  signal score3_cell                                : unsigned(12 downto 0);
  signal score4_cell                                : unsigned(12 downto 0);
  signal next_head_cell                             : unsigned(12 downto 0)        := to_unsigned(2360, 13);  -- cell 2360
  signal next_tail_cell                             : unsigned(12 downto 0)        := to_unsigned(2440, 13);  -- cell 2360
  -- signal clearcell : unsigned(12 downto 0) := to_unsigned(0, 13);
  signal speed                                      : unsigned(4 downto 0)         := "11111";  -- slowest speed
  signal score                                      : unsigned(13 downto 0);
  signal color                                      : unsigned (1 downto 0);
  signal current_direction                          : unsigned(2 downto 0);
  signal skill                                      : unsigned(4 downto 0)         := "00000";  -- skill 0
  signal WE_head                                    : std_logic;
  signal WE_tail                                    : std_logic;
  signal WE_corner                                  : std_logic;
  signal WE_score1, WE_score2, WE_score3, WE_score4 : std_logic                    := '0';  -- registers for the cell updater
  signal next_direction                             : unsigned(2 downto 0);
  signal body_character                             : unsigned(12 downto 0)        := to_unsigned(3*8, 13);
  signal old_body_character                         : unsigned(12 downto 0);
  signal write_data_head                            : unsigned(15 downto 0);
  signal write_data_tail                            : unsigned(15 downto 0);
  signal write_data_corner                          : unsigned(15 downto 0);
  signal write_data_score1                          : unsigned(15 downto 0);
  signal write_data_score2                          : unsigned(15 downto 0);
  signal write_data_score3                          : unsigned(15 downto 0);
  signal write_data_score4                          : unsigned(15 downto 0);
  signal write_enable                               : std_logic;
  signal write_job                                  : std_logic_vector(2 downto 0) := "000";  -- signal for cell update pipeline
  signal crash_check                                : std_logic                    := '0';  -- register to activate the  crash checker
  signal crash_test                                 : std_logic_vector(1 downto 0) := "00";  -- crash check pipeline
  signal crashed                                    : std_logic                    := '0';  -- register to activate the crashed state
  signal reset_game                                 : std_logic                    := '0';  -- register to restart game
  signal game_reset                                 : std_logic                    := '0';  -- register to signal end of reset
  signal move_snake : std_logic := '0';  -- when timer reaches max he snake is moved.
  
  
  --- STATE MACHINE SIGNALS
  type state_t is (IDLE, HEAD, CORNER, TAIL, SCORE, RESET);
  signal state : state_t;
  
  
  
begin

  EN_int  <= '1';
  colour  <= color;
  WEA_int <= write_enable;



-- purpose: controls which state the game logic is in
-- type   : sequential
-- inputs : clk25, ext_reset, tick, head_done, corner_done, corner, score, tail_done, crashed, reset_done
-- outputs: state
p_state_machine: process (clk25, ext_reset)
begin  -- process p_state_machine
  if ext_reset = '1' then               -- asynchronous reset (active high)
    state <= IDLE;
  elsif clk25'event and clk25 = '1' then  -- rising clock edge
    case state is
      when IDLE  => 
         if tick ='1' then
                    state <= HEAD;  
                    end if;
      when HEAD =>
                    if (head_done = '1') and (corner = '1') then
                      state <= CORNER;
                    elsif (head_done = '1') and (corner = '0') then
                      state <= TAIL;
                    elsif (crashed = '1') then
                      state <= RESET;
                    end if;
      when CORNER =>
                    if (corner_done = '1') then
                      state <= TAIL;
                    end if;
      when TAIL =>
                    if (tail_done = '1') and (score = '0') then
                      state <= IDLE;
                    elsif (tail_done = '1') and (score = '1') then
                      state  <= SCORE;
                    end if;
      when SCORE =>
                    if (score_done = '1') then
                      state <= IDLE;
                    end if;
      when RESET =>
                    if (reset_done = '1') then
                      state <= IDLE;
                    end if;                  
    end case;
  end if;
end process p_state_machine;


  

-- purpose: updates the user input from keyboard
-- type   : sequential
-- inputs : clk25, ext_reset, Direction, crashed
-- outputs: next_direction, reset_game
p_keyboard_input: process (clk25, ext_reset)
begin  -- process p_keyboard_input
  if ext_reset = '0' then               -- asynchronous reset (active low)
    next_direction = (others => '0');
  elsif clk25'event and clk25 = '1' then  -- rising clock edge
-- update keyboard input      
      if (Direction /= "000") and (Direction /= "101") then
        next_direction <= Direction;
      elsif (Direction = "101") and (crashed = '1') then
        next_direction <= "111";
      end if;
-- end of keyboard update
  end if;
end process p_keyboard_input;


-- purpose: controls the speed of the snake
-- type   : sequential
-- inputs : clk25, ext_reset, skill, game_reset, snake_moved
-- outputs: move_snake
p_snake_timer: process (clk25, ext_reset, game_reset)
    variable cnt : integer;
begin  -- process p_snake_timer
  if (ext_reset = '0') or (game_reset = '1') then          -- asynchronous reset (active low)
    move_snake <= '0';
  elsif clk25'event and clk25 = '1' then  -- rising clock edge   
      cnt := cnt + 1;
      if (cnt = 5000000) then
        move_snake <= '1'; -- move snake head every time the  timer reaches max.
        cnt := 0;
      elsif (snake_moved = '1') then
        move_snake <= '0';
   end if;
end process p_snake_timer;

-- purpose: checks if the snake has crashed into a border or itself
-- type   : sequential
-- inputs : clk25, ext_reset, crash_check, next_head_cell, output_a_int, crash_result_ready
-- outputs: crash_test, crashed
p_collision_checker: process (clk25, ext_reset, game_reset)
begin  -- process p_collision_checker
  if (ext_reset = '0') or (game_reset = '0') then               -- asynchronous reset (active low)
    crash_test <= (others => '0');
    crashed <= '0';
  elsif clk25'event and clk25 = '1' then  -- rising clock edge


    
          if (crash_check = '1') then
            if (crash_test = "00") then
        --    address_a_int  <= next_head_cell;
              crash_test <= "01";
            elsif (crash_result_ready = '1') then
              crash_test <= (others => '0');
              if (to_integer(output_a_int) /= 0) then
                crashed <= '1';
              else
                crashed <= '0';
              end if;        
            end if;
          end if;
  end if;
end process p_collision_checker;



            


  p_movesnake : process (clk25, ext_reset, game_reset)
  
  begin
    if (ext_reset = '1') or (game_reset = '1') then  -- asynchronous reset (active low)
      current_direction <= (others => '0');
 --     speed             <= (others => '0');     -- slowest speed
 --     skill             <= (others => '0');          -- lowest skill
      body_character    <= to_unsigned(3*8, 13);     --     
      WE_corner         <= '0';
      WE_tail           <= '0';
      WE_score1         <= '0';
      WE_score2         <= '0';
      WE_score3         <= '0';
      WE_score4         <= '0';
      write_data_corner <= (others => '0');
      write_data_tail   <= (others => '0');
      write_data_score1 <= (others => '0');
      write_data_score2 <= (others => '0');
      write_data_score3 <= (others => '0');
      write_data_score4 <= (others => '0');
      crash_check       <= '0';
      reset_game        <= '0';
      next_head_cell    <= to_unsigned(2360, head_cell'length);
      write_data_head   <= current_direction & body_character;
      WE_head           <= '1';
      corner_cell       <= (others => '0');
      
      
    elsif clk25'event and clk25 = '1' then  -- rising clock edge


--update display buffer for ram writer process
      if (write_enable = '1') then
        if (write_job = "001") then
          WE_head <= '0';
        elsif (write_job = "010") then
          WE_corner <= '0';
        elsif (write_job = "011") then
          WE_tail <= '0';
        elsif (write_job = "100") then
          WE_score1 <= '0';
        elsif (write_job = "101") then
          WE_score2 <= '0';
        elsif (write_job = "110") then
          WE_score3 <= '0';
        elsif (write_job = "111") then
          WE_score4 <= '0';
        end if;
      end if;



--update crash check pipeline
      if (check_progress = "11") then
        crash_check <= '0';
      end if;


      if (move_snake = '0')  then
        WE_head     <= '1';
        crash_check <= '1';
        if (next_direction = current_direction) then  -- IF NO CHANGE IN DIRECTION
          if (current_direction = "001") then  -- moving vertical
            next_head_cell <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
          elsif (current_direction = "010") then      -- moving right
            next_head_cell <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
          elsif (current_direction = "011") then      -- moving down
            next_head_cell <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
          elsif (current_direction = "100") then      -- moving right
            next_head_cell <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
          end if;
          write_data_head <= current_direction & body_character;
        else
          if (current_direction = "001") then  -- IF moving UP before change
            if (next_direction = "010") then   -- turns RIGHT
              old_body_character <= to_unsigned(6*8, body_character'length);
              body_character     <= to_unsigned(2*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
              current_direction  <= "010";
              WE_corner          <= '1';
            elsif (next_direction = "100") then       -- turns LEFT
              old_body_character <= to_unsigned(7*8, body_character'length);
              body_character     <= to_unsigned(2*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
              current_direction  <= "100";
              WE_corner          <= '1';
            else
              next_head_cell <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
            end if;
            
          elsif (current_direction = "011") then  -- IF moving DOWN befoe change
            if (next_direction = "010") then      -- turns RIGHT
              old_body_character <= to_unsigned(5*8, body_character'length);
              body_character     <= to_unsigned(2*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
              current_direction  <= "010";
              WE_corner          <= '1';
            elsif (next_direction = "100") then   -- turns  LEFT
              old_body_character <= to_unsigned(4*8, body_character'length);
              body_character     <= to_unsigned(2*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
              current_direction  <= "100";
              WE_corner          <= '1';
            else
              --      body_character <= to_unsigned(3*8, body_character'length);
              next_head_cell <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
            end if;
            
          elsif (current_direction = "010") then  -- IF moving RIGHT before change
            if (next_direction = "001") then      -- turns UP
              old_body_character <= to_unsigned(5*8, body_character'length);
              body_character     <= to_unsigned(3*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
              current_direction  <= "001";
              WE_corner          <= '1';
            elsif (next_direction = "011") then   -- turns  DOWN
              old_body_character <= to_unsigned(7*8, body_character'length);
              body_character     <= to_unsigned(3*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
              current_direction  <= "011";
              WE_corner          <= '1';
            else
              --    body_character <= to_unsigned(2*8, body_character'length);
              next_head_cell <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
            end if;
            
          elsif (current_direction = "100") then  -- IF moving LEFT before change
            if (next_direction = "001") then      -- turns UP
              old_body_character <= to_unsigned(4*8, body_character'length);
              body_character     <= to_unsigned(3*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
              current_direction  <= "001";
              WE_corner          <= '1';
            elsif (next_direction = "011") then   --turns DOWN
              old_body_character <= to_unsigned(6*8, body_character'length);
              body_character     <= to_unsigned(3*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
              current_direction  <= "011";
              WE_corner          <= '1';
            else
              next_head_cell <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
            end if;
            
          end if;
          write_data_corner <= Direction & old_body_character;
          write_data_head   <= Direction & body_character;
          corner_cell       <= head_cell;
        end if;
        
      end if;
    end if;
    
  end process p_movesnake;
  
  
  

--  -- purpose: updates the ram entries for the video display
--  -- type   : sequential
--  -- inputs : clk25, ext_reset, WE_head, WE_tail, WE_corner, write_data_head,
--  -- write_data_tail, write_data_corner, head_cell, corner_cell, tail_cell,
--  -- WE_score1, WE_Score2, WE_score3, WE_score4, write_data_score1, write_data_score2, write_data_score3, write_data_score4
--  -- outputs : address_a_int, write_enable, input_a_int, write_job
--  p_cellupdate : process (clk25, ext_reset, game_reset)
--    variable ramcnt_i : integer;
--    variable ramcnt_j : integer;
--  begin  -- process p_cellupdate
--    if (ext_reset = '1') or (game_reset = '1') then  -- asynchronous reset (active high)
--      write_job      <= (others => '0');
--      head_cell      <= to_unsigned(2440, head_cell'length);
--      tail_cell      <= to_unsigned(2440, tail_cell'length);
--      check_progress <= (others => '0');
--      crashed        <= '0';
--      ramcnt_i       := 0;
--      ramcnt_j       := 0;
--      write_enable   <= '0';
--      game_reset     <= '0';
--      head_cell      <= to_unsigned(2440, head_cell'length);
--      tail_cell      <= to_unsigned(2440, tail_cell'length);
--      crashed        <= '0';
--		
--    elsif clk25'event and clk25 = '1' then  -- rising clock edge  
--      if (reset_game = '1') then
--        write_enable <= '1';
--        input_a_int  <= (others => '0');
--        ramcnt_i     := ramcnt_i + 1;
--        if (ramcnt_i = 80) then
--          ramcnt_j := ramcnt_j + 1;
--          ramcnt_i := 0;
--          if (ramcnt_j = 55) then
--            game_reset <= '1';
--          end if;
--        end if;
--        if (ramcnt_i > 0) and (ramcnt_i < 79) and (ramcnt_j > 0) and (ramcnt_j < 55) then
--          address_a_int <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a_int'length);
--          input_a_int   <= (others => '0');
--        else
--          address_a_int <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a_int'length);
--          input_a_int   <= to_unsigned(8, input_a_int'length);
--        end if;
--      end if;
--
--      if (crashed = '1') then
--        -- CRASHED STATE
--
--
--
--      else
--        if (WE_head = '1') then
--
--
--          else
--            write_job     <= "001";
--            input_a_int   <= write_data_head;
--            head_cell     <= next_head_cell;
--            address_a_int <= head_cell;
--            write_enable  <= '1';
--          end if;
--
--        elsif (WE_corner = '1') then
--          write_job     <= "010";
--          input_a_int   <= write_data_corner;
--          address_a_int <= corner_cell;
--          write_enable  <= '1';
--        elsif (WE_tail = '1') then
--          write_job     <= "011";
--          input_a_int   <= write_data_tail;
--          address_a_int <= tail_cell;
--          write_enable  <= '1';
--        elsif (WE_score1 = '1') then
--          write_job     <= "100";
--          input_a_int   <= write_data_score1;
--          address_a_int <= score1_cell;
--          write_enable  <= '1';
--        elsif (WE_score2 = '1') then
--          write_job     <= "101";
--          input_a_int   <= write_data_score2;
--          address_a_int <= score2_cell;
--          write_enable  <= '1';
--        elsif (WE_score3 = '1') then
--          write_job     <= "110";
--          input_a_int   <= write_data_score3;
--          address_a_int <= score3_cell;
--          write_enable  <= '1';
--        elsif (WE_score4 = '1') then
--          write_job     <= "111";
--          input_a_int   <= write_data_score4;
--          address_a_int <= score4_cell;
--          write_enable  <= '1';
--        else
--          write_enable <= '0';
--          write_job    <= (others => '0');
--        end if;
--      end if;
--    end if;
--  end process p_cellupdate;



end Behavioral;

