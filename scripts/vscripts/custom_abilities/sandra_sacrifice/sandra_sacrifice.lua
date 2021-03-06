sandra_sacrifice = class({})
LinkLuaModifier( "modifier_sandra_sacrifice", "custom_abilities/sandra_sacrifice/modifier_sandra_sacrifice", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sandra_sacrifice_master", "custom_abilities/sandra_sacrifice/modifier_sandra_sacrifice_master", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sandra_sacrifice_pull", "custom_abilities/sandra_sacrifice/modifier_sandra_sacrifice_pull", LUA_MODIFIER_MOTION_HORIZONTAL )
local tempTable = require("util/tempTable")

--------------------------------------------------------------------------------
-- Ability Cast Filter
function sandra_sacrifice:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		0,
		self:GetCaster():GetTeamNumber()
	)
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function sandra_sacrifice:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return ""
end

--------------------------------------------------------------------------------
-- Ability Start
function sandra_sacrifice:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = self:GetSpecialValueFor("leash_duration")

	-- destroy previous cast
	local modifier = caster:FindModifierByNameAndCaster( "modifier_sandra_sacrifice", caster )
	if modifier then
		modifier:Destroy()
	end

	-- add slave modifier
	local master = tempTable:AddATValue( target )
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_sandra_sacrifice", -- modifier name
		{
			duration = duration,
			master = master,
		} -- kv
	)
end

--------------------------------------------------------------------------------
-- Helper: Flag operations
function sandra_sacrifice:FlagExist(a,b)--Bitwise Exist
	local p,c,d=1,0,b
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c==d
end

function sandra_sacrifice:FlagAdd(a,b)--Bitwise and
	if FlagExist(a,b) then
		return a
	else
		return a+b
	end
end

function sandra_sacrifice:FlagMin(a,b)--Bitwise and
	if FlagExist(a,b) then
		return a-b
	else
		return a
	end
end