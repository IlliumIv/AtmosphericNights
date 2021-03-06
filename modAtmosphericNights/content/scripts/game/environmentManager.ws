/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
enum EMoonState
{
	EMS_NotFull,
	EMS_Full,
	EMS_Red,
	EMS_Any
}

function GetCurMoonState() : EMoonState
{
	if (theGame.envMgr.IsFullMoon())
	{
		if (theGame.envMgr.IsRedMoon())
		{
			return EMS_Red;
		}
		else
		{
			return EMS_Full;
		}
	}
	return EMS_NotFull;
}

enum EWeatherEffect
{
	EWE_Clear,
	EWE_Rain,
	EWE_Snow,
	EWE_Storm,
	EWE_None,
	EWE_Any
}

function GetCurWeather() : EWeatherEffect
{
	var rain, snow : float;

	rain = GetRainStrength();
	snow = GetSnowStrength();

	if (rain > 0 && rain > snow)
	{
		if(rain == 1)
			return EWE_Storm;
		else
			return EWE_Rain;
	}
	else if (snow > 0 && snow > rain)
	{
		return EWE_Snow;
	}
	else if (IsSkyClear())
	{
		return EWE_Clear;
	}
	
	return EWE_None;
}

struct SWeatherBonus
{
	var dayPart : EDayPart;
	var weather : EWeatherEffect;
	var moonState : EMoonState;
	
	var ability : name;
}

class W3EnvironmentManager
{
	saved var m_envId : int;
	var lunation : int;
	default lunation = 24; 
	var dayStart : int;
	default dayStart = 3; 
	var nightStart : int;
	default nightStart = 22;
	var redMoonPeriod : int;
	default redMoonPeriod = 3;
	var hourToSwitchEnv : int;
	default hourToSwitchEnv = 14;

	public function Initialize()
	{
		m_envId = -1;
	}
	
	public function Update()
	{
		CheckRedMoon();
	}

	
	public function CheckRedMoon()
	{
		var currentGameTime : GameTime;
		var hours : int;
		
		currentGameTime = theGame.GetGameTime();
		hours = GameTimeHours(currentGameTime);
		
		if (m_envId == -1)
		{
			if (IsDay() && hours >= hourToSwitchEnv && IsRedMoon(true))
			{
				
			}
		}
		else
		{
			if (IsDay() && hours >= hourToSwitchEnv && !IsRedMoon(true))
			{
				
				m_envId = -1;
			}
		}
	}


	
	final function IsNight() : bool
	{
		var hours: int ;
		hours = GameTimeHours(theGame.GetGameTime());
		
		if(hours >= nightStart || hours < dayStart)			
		{
			return true;
		}
		return false;
	}

	
	final function IsDay() : bool
	{
		return !IsNight();
	}
	
	public function GetGameTimeTillNextNight() : GameTime
	{
		return GetGameTimeTillNextHour(nightStart);
	}
	
	public function GetGameTimeTillNextDay() : GameTime
	{
		return GetGameTimeTillNextHour(dayStart);
	}
	
	public function GetGameTimeTillNextHour(targetHour : int) : GameTime
	{
		var currDate, targetDate, dateDiff : GameTime;
		var day, hour : int;
		
		currDate = theGame.GetGameTime();
		day = GameTimeDays(currDate);
		hour = GameTimeHours(currDate);
		
		if(hour >= targetHour)
			day += 1;
		
		targetDate = GameTimeCreate(day, targetHour, 0, 0);
		
		dateDiff = targetDate - currDate;
		
		return dateDiff;
	}
	
	private function GetNightNum() : int
	{
		var currentGameTime : GameTime;
		var nightNum : int;
		var hours : int;
		
		currentGameTime = theGame.GetGameTime();
		nightNum = GameTimeDays(currentGameTime);
		
		hours = GameTimeHours(currentGameTime);
		if (hours > 12) 
		{
			nightNum += 1;
		}
		return nightNum;
	}
	
	public function IsFullMoon(optional dontCheckNightCond : bool) : bool
	{
		var currentGameTime : GameTime;
		var moonStage : int;
		var hours : int;
		
		if (!dontCheckNightCond && !IsNight())
		{
			return false;
		}
		
		moonStage = GetNightNum() % lunation;
		
		if (moonStage == 8)
		{
			return true;
		}
		
		return false;
	}
	
	public function IsRedMoon(optional dontCheckNightCond : bool) : bool
	{
		var moonPeriods : int;	
	
		if (!IsFullMoon(dontCheckNightCond))
		{
			return false;
		}
		
		moonPeriods = GetNightNum() / lunation;
		
		moonPeriods = moonPeriods % redMoonPeriod;
		if (moonPeriods == 2)
		{
			return true;
		}
		
		return false;
	}
	
	//Shaedhen - Atmospheric Nights - Starts here
	final function IsAlmostNight(diff : int) : bool
	{
		var hours: int ;
		var almostNight: int;
		var difference : int;
		difference = diff/60;
		almostNight = nightStart - difference;
		hours = GameTimeHours(theGame.GetGameTime());
		if(hours >= almostNight && hours < nightStart)			
		{
			return true;
		}
		return false;
	}
	final function GetTimeInMinutes() : int
	{
		var currentGameTime : GameTime;
		var hoursAndMins : int;
		
		currentGameTime = theGame.GetGameTime();
		hoursAndMins = GameTimeHours(currentGameTime)*60;
		hoursAndMins += GameTimeMinutes(currentGameTime);
		return hoursAndMins;
	
	}
	
	final function GetMinutesForTime(gt : GameTime) : int
	{
	var currentGameTime : GameTime;
		var hoursAndMins : int;
		
		currentGameTime = gt;
		hoursAndMins = GameTimeHours(currentGameTime)*60;
		hoursAndMins += GameTimeMinutes(currentGameTime);
		return hoursAndMins;
	}
	
	public function SetDayStartAt(ds : int)
	{
		dayStart = ds;
	}
	
	public function SetNightStart(ns : int)
	{
		nightStart = ns;
	}
	
	final function IsStartingDay(diff : int) : bool
	{
		var hours: int ;
		var startingDay: int;
		var difference : int;
		difference = diff/60;
		//startingDay will be equal to 6am.
		startingDay = dayStart+difference;
		hours = GameTimeHours(theGame.GetGameTime());
		
		if(hours >= dayStart && hours < startingDay)			
		{
			return true;
		}
		return false;
	}
	
	public function GetGameTimeTillNextAlmostNight() : GameTime
	{
		return GetGameTimeTillNextHour(20);
	}
	
	public function GetGameTimeTillNextStartedDay(refresh : int) : GameTime
	{
		var currDate, targetDate, dateDiff : GameTime;
		var day, hour,mins : int;
		var totalTime : int;
		var hourB,minsB : int;
		currDate = theGame.GetGameTime();
		day = GameTimeDays(currDate);
		hour = GameTimeHours(currDate);
		mins = GameTimeMinutes(currDate);
		totalTime = (hour*60)+mins+refresh;
		hourB = totalTime/60;
		minsB = totalTime -(hourB*60);
		targetDate = GameTimeCreate(day, hourB, minsB, 0);
		dateDiff = targetDate - currDate;
		return dateDiff;
	}
	//Shaedhen - Atmospheric Nights - Ends here
}