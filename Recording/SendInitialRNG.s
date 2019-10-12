.include "./Recording.s"

.macro Macro_SendInitialRNG

CreateInitialRNGProc:
#Create GObj
  li	r3,4	    	#GObj Type (4 is the player type, this should ensure it runs before any player animations)
  li	r4,7	  	  #On-Pause Function (dont run on pause)
  li	r5,0        #some type of priority
  branchl	r12,GObj_Create

#Create Proc
  bl  SendInitialRNG
  mflr r4         #Function
  li  r5,0        #Priority
  branchl	r12,GObj_AddProc

b CreateInitialRNGProc_Exit

################################################################################
# Routine: SendInitialRNG
# ------------------------------------------------------------------------------
# Description: Sends the RNG seed that is needed for the very rare case of throws
# causing the DamageFlyTop state
################################################################################

SendInitialRNG:
blrl

.set REG_PlayerData,31
.set REG_Buffer,29
.set REG_BufferOffset,28
.set REG_PlayerSlot,27
.set REG_GameEndID,26
.set REG_SceneThinkStruct,25

backup

#------------- INITIALIZE -------------
# here we want to initalize some variables we plan on using throughout
# get current offset in buffer
  lwz REG_Buffer,frameDataBuffer(r13)
  lwz REG_BufferOffset,bufferOffset(r13)
  add REG_Buffer,REG_Buffer,REG_BufferOffset

# initial RNG command byte
  li r3, 0x3A
  stb r3,0x0(REG_Buffer)

# send frame count
  lwz r3,frameIndex(r13)
  stw r3,0x1(REG_Buffer)

# store RNG seed
  lis r3, 0x804D
  lwz r3, 0x5F90(r3) #load random seed
  stw r3,0x5(REG_Buffer)

#------------- Increment Buffer Offset ------------
  lwz REG_BufferOffset,bufferOffset(r13)
  addi REG_BufferOffset,REG_BufferOffset,(GAME_INITIAL_RNG_PAYLOAD_LENGTH+1)
  stw REG_BufferOffset,bufferOffset(r13)

SendInitialRNG_Exit:
  restore
  blr

CreateInitialRNGProc_Exit:

.endm
