local Constants = {
	SpeedMultiplier = 1.18, -- every 5 seconds will increase by "Multiplier value" times of the base speed
	MaxSpeed = 3.6, -- the max speed multipler
	
	SpeedUpdateTimer = 10, -- the time it takes for the speed and interval to update
	WordUpdateTimer = 8, -- the time it takes for the wordlist to update
	
	SpeedChangePerLetter = 1.055, -- the change in speed per letter difference from the meanspeedwordlength
	MeanSpeedWordLength = 5, -- the length of word so that the speed will be normal
	
	IntervalMultiplier = 0.952, -- every 5 seconds will increase by 1.05x of the base interval (original 0.955)
	MinInterval = 0.09, -- the min interval multiplier
	
	Lives = 3, -- how many words the ship can tolerate
	
	PointsPerLetter = 1,
	WordsForCombo = 10,
	ComboMultiplier = 2
}

return Constants
