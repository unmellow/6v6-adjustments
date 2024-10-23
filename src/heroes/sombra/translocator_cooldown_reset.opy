#!mainFile "../../dev_main.opy"

#Player variables

playervar stealth_timer 0
playervar stealth_max_Cooldown 1
    
rule "[sombra/translocator_cooldown_reset.opy]: When Translocator is used, begin tracking how long Sombra is in stealth":
    @Event eachPlayer
    @Hero sombra
    @Condition eventPlayer.isUsingAbility2() == true
    
    eventPlayer.stealth_timer = OW2_SOMBRA_STEALTH_DURATION + OW2_SOMBRA_STEALTH_CAST_TIME
    waitUntil(eventPlayer.isUsingAbility2() == false, 1000000)
    chase(eventPlayer.stealth_timer, 0, rate=1, ChaseReeval.NONE)
    #Sombra can't break stealth during the cast time of stealth
    wait(OW2_SOMBRA_STEALTH_CAST_TIME, Wait.RESTART_WHEN_TRUE)
    #Wait until Sombra exits Stealth
    waitUntil(any([eventPlayer.hasStatusEffect(Status.ASLEEP), eventPlayer.hasStatusEffect(Status.FROZEN), eventPlayer.hasStatusEffect(Status.HACKED), eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN), eventPlayer.hasStatusEffect(Status.STUNNED), eventPlayer.hasStatusEffect(Status.ROOTED)]) or eventPlayer.isFiringPrimaryFire() or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and not eventPlayer.isFiringSecondaryFire() or eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0 and eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isHoldingButton(Button.MELEE) or eventPlayer.isMeleeing() or eventPlayer.isUsingUltimate(), 5)
    stopChasingVariable(eventPlayer.stealth_timer)
    if eventPlayer.stealth_timer <= 0:
        return
    if ADJ_SOMBRA_NEGATIVE_STATUS_PREVENTS_REFUND:
        if any([eventPlayer.hasStatusEffect(Status.ASLEEP), eventPlayer.hasStatusEffect(Status.FROZEN), eventPlayer.hasStatusEffect(Status.HACKED), eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN), eventPlayer.hasStatusEffect(Status.STUNNED), eventPlayer.hasStatusEffect(Status.ROOTED)]):
            return
    waitUntil(eventPlayer.getAbilityCooldown(Button.ABILITY_2) > 0, 1)
    printLog("Current Translocator Cooldown: {0} | Target Translocator Cooldown: {1}".format(eventPlayer.getAbilityCooldown(Button.ABILITY_2), eventPlayer.stealth_max_Cooldown - 5 + (eventPlayer.stealth_timer * (1 - ADJ_SOMBRA_STEALTH_REFUND_FRACTION))))
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, eventPlayer.stealth_max_Cooldown - OW2_SOMBRA_STEALTH_DURATION - OW2_SOMBRA_STEALTH_CAST_TIME + (eventPlayer.stealth_timer * (1 - ADJ_SOMBRA_STEALTH_REFUND_FRACTION)))
    
    
rule "[sombra/translocator_cooldown_reset.opy]: Set max stealth cooldown observed":
    @Event eachPlayer
    @Hero sombra
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) > eventPlayer.stealth_max_Cooldown
    
    eventPlayer.stealth_max_Cooldown = round(eventPlayer.getAbilityCooldown(Button.ABILITY_2))