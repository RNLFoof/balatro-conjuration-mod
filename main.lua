sealCalculateFunction = function(self, card, context)
    function cardStr(card)
        if card == nil then
            return "[??? ???]"
        end
        if card.base == nil then
            return "[???]"
        end
        return string.format("[%d%s $s]", card.base.id, card.base.suit, card.seal)
    end

    print(cardStr(card), "Evaluating seal")
    -- main_scoring context is used whenever the card is scored
    if context.main_scoring and context.cardarea == G.play then
        -- get the index of the card within the scoring cards
        print(cardStr(card), "correct context")
        
        -- So, all the cards are evaluated before the animations play.
        -- This means that in order to have the seal visibly transfer between multiple cards,
        -- Each card needs to find out if it *will* be transfered to them.
        cardWithSeal = card
        passesBetween = {}
        for i, checkingCard in pairs(context.scoring_hand) do
            if checkingCard == cardWithSeal then
                cardIndex = i
                if cardIndex ~= #context.scoring_hand then
                    nextCardIndex = cardIndex+1
                    nextCard = context.scoring_hand[nextCardIndex]
                    
                    -- if the next card is sequential and sealess, pass the seal on
                    print(cardStr(cardWithSeal), "debug vars")
                    print(cardStr(cardWithSeal), "four", 4)
                    print(cardStr(cardWithSeal), "rank", cardWithSeal.rank)
                    print(cardStr(cardWithSeal), "next card rank", nextCard.rank)
                    print(cardStr(cardWithSeal), "real rank", nextCard.base.id)
                    if cardWithSeal.base.id + 1 == nextCard.base.id and nextCard.seal == nil then
                        print(cardStr(cardWithSeal), "confirmed, passing to", cardStr(nextCard))
                        local cardWithSealInEvent = context.scoring_hand[cardIndex]
                        local nextCardInEvent = context.scoring_hand[nextCardIndex]
                        spacing = 0.001

                        G.E_MANAGER:add_event(Event({delay=spacing,trigger="after",func = function()
                            print(cardStr(cardWithSealInEvent), "playing animation of passing to", cardStr(nextCardInEvent))
                            cardWithSealInEvent:flip()
                            return true
                        end;}))
                                    
                        G.E_MANAGER:add_event(Event({delay=spacing,trigger="after",func = function()
                                    nextCardInEvent:flip()
                                    return true
                        end;}))
                        G.E_MANAGER:add_event(Event({delay=spacing,trigger="after",func = function()
                                    cardWithSealInEvent:set_seal(nil, true, true)
                                    nextCardInEvent:set_seal('conj_indigo', true, true)
                                    return true
                        end;}))
                        G.E_MANAGER:add_event(Event({delay=spacing,trigger="after",func = function()
                                    cardWithSealInEvent:flip()
                                    return true
                        end;}))
                        G.E_MANAGER:add_event(Event({delay=spacing,trigger="after",func = function()
                                    nextCardInEvent:flip()
                                    return true
                        end;}))
                        sealCalculateFunction(self, nextCardInEvent, context)
                            
                        break
                    end
                end
            end
        end
        
        -- if this is the last card, bail, otherwise take note
        print(cardStr(card), "3")
    end
end

indigoSeal = SMODS.Seal {
    name = "modded-Seal",
    key = "indigo",
    badge_colour = HEX("5729e0"),
	config = { mult = -1, chips = -1, money =  -1, x_mult = -1  },
    loc_txt = {
        -- Badge name (displayed on card description when seal is applied)
        label = 'Indigo Seal',
        -- Tooltip description
        name = 'Indigo Seal',
        -- This could really use more concise phrasing...
        text = {
            "Travels upwards between scored",
            "{C:attention}position & rank{} sequential cards.",
            "Upon reaching an Ace,",
            "is removed and creates a",
            "{C:dark_edition}negative{} {C:attention}Stars{}.",
            "{C:inactive}Ex: A[J to Q]2K, 78[4 to 5 to 6]"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {self.config.mult, self.config.chips, self.config.money, self.config.x_mult, } }
    end,
    atlas = "seal_atlas",
    pos = {x=0, y=0},

    -- self - this seal prototype
    -- card - card this seal is applied to
    calculate = sealCalculateFunction
}

SMODS.Atlas {
    key = "seal_atlas",
    path = "modded_seal.png",
    px = 71,
    py = 95
}

-- Create consumable that will add this seal.

SMODS.Consumable {
    set = "Spectral",
    key = "conjuration",
	config = {
        -- How many cards can be selected.
        max_highlighted = 1,
        -- the key of the seal to change to
        extra = 'conj_indigo',
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'Conjuration',
        text = {
            "Add an {C:attention}Indigo Seal{}",
            "to {C:attention}#1#{} selected",
            "card in your hand",
        }
    },
    cost = 4,
    atlas = "conjuration_atlas",
    pos = {x=0, y=0},
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:set_seal(card.ability.extra, nil, true)
                return true end }))
            
            delay(0.5)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

SMODS.Atlas {
    key = "conjuration_atlas",
    path = "conjuration.png",
    px = 71,
    py = 95
}