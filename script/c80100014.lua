--サイバネティック・フュージョン・サポート
function c80100014.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c80100014.cost)
	e1:SetOperation(c80100014.activate)
	c:RegisterEffect(e1)
end
function c80100014.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,80100014)==0 end
	Duel.PayLPCost(tp,Duel.GetLP(tp)/2)
	Duel.RegisterFlagEffect(tp,80100014,RESET_PHASE+PHASE_END,0,1)
end
function c80100014.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(80100014,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHAIN_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(c80100014.chain_condition)
	e1:SetTarget(c80100014.chain_target)
	e1:SetOperation(c80100014.chain_operation)
	Duel.RegisterEffect(e1,tp)
end
function c80100014.chain_condition(e,tp,eg,ep,ev,re,r,rp)
	local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
	local mg1=Duel.GetMatchingGroup(c80100014.filter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,nil,e)
	local res=Duel.IsExistingMatchingCard(c80100014.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			res=Duel.IsExistingMatchingCard(c80100014.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,chkf)
		end
	end
	return res
end
function c80100014.filter(c,e)
	return c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c80100014.filter2(c,e,tp,m,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,chkf)
end
function c80100014.chain_target(e,te,tp)
	return Duel.GetMatchingGroup(c80100014.filter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,nil,te)
end
function c80100014.chain_operation(e,te,tp,tc,mat,sumtype)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(80100014,RESET_EVENT+0x1fc0000+RESET_PHASE+RESET_END,0,1)
end