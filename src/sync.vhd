-- =============================================================================
-- Authors: Patrick Lehmann
--
-- Entity: sync_Bits_Altera
--
-- Description:
-- -------------------------------------
-- This is a multi-bit clock-domain-crossing circuit optimized for Altera FPGAs.
-- It generates 2 flip flops per input bit and notifies Quartus, that these
-- flip flops are synchronizer flip flops. If you need a platform independent
-- version of this synchronizer, please use `PoC.misc.sync.Flag`, which
-- internally instantiates this module if an Altera FPGA is detected.
--
-- .. ATTENTION:
-- Use this synchronizer only for long time stable signals (flags).
--
-- CONSTRAINTS:
--
-- License:
-- =============================================================================
-- Copyright 2007-2016 Technische Universitaet Dresden - Germany
-- Chair of VLSI-Design, Diagnostics and Architecture
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =============================================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sync IS
	GENERIC (
		INIT       : std_logic := '0'; -- initialization bits
		SYNC_DEPTH : POSITIVE := 2 -- generate SYNC_DEPTH many stages, at least 2
	);
	PORT (
		Clock  : IN std_logic; --  output clock domain
		Input  : IN std_logic; -- @async: input bits
		Output : OUT std_logic -- @Clock: output bits
	);
END ENTITY;
ARCHITECTURE rtl OF sync IS
	ATTRIBUTE PRESERVE         : BOOLEAN;
	ATTRIBUTE ALTERA_ATTRIBUTE : STRING;

	-- Apply a SDC constraint to meta stable flip flop, i.e. set_false_path
	ATTRIBUTE ALTERA_ATTRIBUTE OF rtl : ARCHITECTURE IS "-name SDC_STATEMENT ""set_false_path -to [get_registers {*|sync:*|\gen:*:Data_meta}] """;
 
	SIGNAL Data_async                 : std_logic;
	SIGNAL Data_meta                  : std_logic := INIT;
	SIGNAL Data_sync                  : std_logic_vector(SYNC_DEPTH - 1 DOWNTO 0) := (OTHERS => INIT);

	-- preserve both registers (no optimization, shift register extraction, ...)
	ATTRIBUTE PRESERVE OF Data_meta : SIGNAL IS TRUE;
	ATTRIBUTE PRESERVE OF Data_sync : SIGNAL IS TRUE;
 
	-- Notify the synthesizer / timing analyzer to identity a synchronizer circuit
	ATTRIBUTE ALTERA_ATTRIBUTE OF Data_meta : SIGNAL IS "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
 
BEGIN
	Data_async <= Input;

	PROCESS (Clock)
	BEGIN
		IF rising_edge(Clock) THEN
			Data_meta <= Data_async;
			Data_sync <= Data_sync(Data_sync'HIGH - 1 DOWNTO 0) & Data_meta;
		END IF;
	END PROCESS;

	Output <= Data_sync(Data_sync'high);

END ARCHITECTURE;