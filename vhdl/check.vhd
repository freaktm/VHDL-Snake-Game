--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the check logic for the snake physics.
--              
-- 
-- 
-- Dependencies: VRAM
-- 
-- 
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.gamelogic_pkg.all;

entity check_logic is
  port(
    gamelogic_state       : in  gamelogic_state_t;
    clk_slow              : in  std_logic;
    ext_reset             : in  std_logic;
    address_a_check       : out unsigned(12 downto 0);
    check_read_data       : in  unsigned(11 downto 0);
    check_done            : out std_logic;
    keyboard              : in  unsigned(2 downto 0);
    crashed               : out std_logic;
    nochange              : out std_logic;
    current_direction_out : out unsigned(2 downto 0);
    old_direction_out     : out unsigned(2 downto 0);
    next_cell             : out unsigned(12 downto 0);
    corner_cell           : out unsigned(12 downto 0)
    );
end check_logic;

architecture Behavioral of check_logic is

  signal   current_direction_int : unsigned(2 downto 0)  := "001";
  signal   next_direction        : unsigned(2 downto 0)  := "001";
  signal   current_cell          : unsigned(12 downto 0) := to_unsigned(2440, 13);
  signal   next_cell_int         : unsigned(12 downto 0) := to_unsigned(2360, 13);
  signal   corner_cell_int       : unsigned(12 downto 0) := (others => '0');
  signal   old_direction_out_int : unsigned(2 downto 0)  := "001";
  signal   nochange_int          : std_logic             := '1';
  signal   crashed_int           : std_logic             := '0';
  signal   check_done_int        : std_logic             := '0';
  constant KEYBOARD_LEFT         : unsigned(2 downto 0)  := "100";
  constant KEYBOARD_RIGHT        : unsigned(2 downto 0)  := "010";
  constant KEYBOARD_UP           : unsigned(2 downto 0)  := "001";
  constant KEYBOARD_DOWN         : unsigned(2 downto 0)  := "011";
  signal   check_direction_done  : std_logic             := '0';
  signal   change_direction_done : std_logic             := '0';
  signal   calc_next_cell_done   : std_logic             := '0';



  type   current_axis_t is (HORIZONTAL, VERTICAL);
  type   check_state_t is (IDLE, CHECK_DIRECTION, CHANGE_DIRECTION, CALC_NEXT_CELL, CHECK_HIT);
  signal check_state  : check_state_t  := IDLE;
  signal current_axis : current_axis_t := VERTICAL;
  
begin


  old_direction_out     <= old_direction_out_int;
  current_direction_out <= current_direction_int;
  address_a_check       <= next_cell_int;
  nochange              <= nochange_int;
  crashed               <= crashed_int;
  corner_cell           <= corner_cell_int;
  check_done            <= check_done_int;


  next_direction <= keyboard;
  next_cell      <= next_cell_int;

  p_check_state : process (clk_slow, ext_reset)
  begin  -- process p_check_state
    if ext_reset = '1' then             -- asynchronous reset (active high)
      check_state <= IDLE;
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      if (gamelogic_state = CHECK) then
        if (check_state = IDLE) then
          check_state <= CHECK_DIRECTION;
        elsif (check_state = CHECK_DIRECTION) then
          if (check_direction_done = '1') and (nochange_int = '0') then
            check_state <= CHANGE_DIRECTION;
          elsif (check_direction_done = '1') and (nochange_int = '1') then
            check_state <= CALC_NEXT_CELL;
          end if;
        elsif (check_state = CHANGE_DIRECTION) then
          if (change_direction_done = '1') then
            check_state <= CALC_NEXT_CELL;
          end if;
        elsif (check_state = CALC_NEXT_CELL) then
          if (calc_next_cell_done = '1') then
            check_state <= CHECK_HIT;
          end if;
        elsif (check_state = CHECK_HIT) then
          if (check_done_int = '1') then
            check_state <= IDLE;
          end if;
        end if;
      else
        check_state <= IDLE;
      end if;
    end if;
  end process p_check_state;




  p_state_CHECK_DIRECTION : process (clk_slow, ext_reset)
  begin  -- process p_state_CHECK_DIRECTION
    if ext_reset = '1' then             -- asynchronous reset (active high)
      check_direction_done  <= '0';
      old_direction_out_int <= KEYBOARD_UP;
      corner_cell_int       <= (others => '0');
      nochange_int          <= '1';
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      if (check_state = CHECK_DIRECTION) then
        check_direction_done <= '1';
        if (current_direction_int /= next_direction) then
          if (current_axis = VERTICAL) then
            if (next_direction = KEYBOARD_RIGHT) or (next_direction = KEYBOARD_LEFT) then
              old_direction_out_int <= current_direction_int;
              corner_cell_int       <= current_cell;
              nochange_int          <= '0';
            end if;
          elsif (next_direction = KEYBOARD_UP) or (next_direction = KEYBOARD_DOWN) then
            old_direction_out_int <= current_direction_int;
            corner_cell_int       <= current_cell;
            nochange_int          <= '0';
          end if;
        else
          nochange_int <= '1';
        end if;
      else
        nochange_int         <= '1';
        check_direction_done <= '0';
      end if;
    end if;
  end process p_state_CHECK_DIRECTION;


  p_CHANGE_DIRECTION : process (clk_slow, ext_reset)
  begin  -- process p_CHANGE_DIRECTION
    if ext_reset = '1' then             -- asynchronous reset (active high)
      current_direction_int <= KEYBOARD_UP;
      change_direction_done <= '0';
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      if (check_state = CHANGE_DIRECTION) then
        current_direction_int <= next_direction;
        change_direction_done <= '1';
      else
        change_direction_done <= '0';
      end if;
    end if;
  end process p_CHANGE_DIRECTION;


  p_CALC_CELL : process (clk_slow, ext_reset)
  begin  -- process p_CALC_CELL
    if ext_reset = '1' then             -- asynchronous reset (active high)
      current_axis        <= VERTICAL;
      current_cell        <= to_unsigned(2440, current_cell'length);
      next_cell_int       <= to_unsigned(2360, next_cell_int'length);
      calc_next_cell_done <= '0';
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      if (check_state = CALC_NEXT_CELL) then
        calc_next_cell_done <= '1';
        if (current_direction_int = KEYBOARD_UP) then
          current_axis  <= VERTICAL;
          next_cell_int <= to_unsigned(to_integer(current_cell) - 80, next_cell_int'length);
        elsif (current_direction_int = KEYBOARD_RIGHT) then
          current_axis  <= HORIZONTAL;
          next_cell_int <= to_unsigned(to_integer(current_cell) + 1, next_cell_int'length);
        elsif (current_direction_int = KEYBOARD_DOWN) then
          current_axis  <= VERTICAL;
          next_cell_int <= to_unsigned(to_integer(current_cell) + 80, next_cell_int'length);
        elsif (current_direction_int = KEYBOARD_LEFT) then
          current_axis  <= HORIZONTAL;
          next_cell_int <= to_unsigned(to_integer(current_cell) - 1, next_cell_int'length);
        end if;
      else
        calc_next_cell_done <= '0';
      end if;
    end if;
  end process p_CALC_CELL;


  p_collision_checker : process (clk_slow, ext_reset)
  begin  -- process p_collision_checker
    if (ext_reset = '1') then  --  asynchronous reset (active high)              
      check_done_int <= '0';
      crashed_int    <= '0';
    elsif (clk_slow'event and clk_slow = '1') then
      if (check_state = CHECK_HIT) then
        check_done_int <= '1';
        if (to_integer(check_read_data) = 0) then
          check_done_int <= '1';
        else
          crashed_int <= '1';
        end if;
      else
        crashed_int    <= '0';
        check_done_int <= '0';
      end if;
    end if;
  end process p_collision_checker;



end Behavioral;
