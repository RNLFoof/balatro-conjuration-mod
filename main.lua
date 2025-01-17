SMODS.Seal {
    name = "modded-Seal",
    key = "indigo",
    badge_colour = HEX("5729e0"),
	config = { mult = -1, chips = -1, money =  -1, x_mult = -1  },
    loc_txt = {
        -- Badge name (displayed on card description when seal is applied)
        label = 'Indigo Seal',
        -- Tooltip description
        name = 'Indigo Seal',
        text = {
            "Travels upwards between played sealess cards when they're directly sequential in both position and rank.",
            "Upon reaching an Ace, is removed and creates a negative FuUCK Joker.",
            "Ex: A♥[J♥→Q♥]2♥K♥, 7♥8♣[4♠→5♣→6♦]"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {self.config.mult, self.config.chips, self.config.money, self.config.x_mult, } }
    end,
    atlas = "seal_atlas",
    pos = {x=0, y=0},

    -- self - this seal prototype
    -- card - card this seal is applied to
    calculate = function(self, card, context)
        function cardStr(card)
            return string.format("[%d%s]", card.base.id, card.base.suit)
        end

        print(cardStr(card), "1")
        -- main_scoring context is used whenever the card is scored
        if context.main_scoring and context.cardarea == G.play then
            -- get the index of the card within the scoring cards
            print(cardStr(card), "2")
            cardIndex = nil
            for i, checkingCard in pairs(context.scoring_hand) do
                if checkingCard == card then
                    cardIndex = i
                    break
                end
            end
            
            -- if this is the last card, bail, otherwise take note
            print(cardStr(card), "3")
            if cardIndex ~= #context.scoring_hand then
                nextCard = context.scoring_hand[cardIndex+1]
                
                -- if the next card is sequential and sealess, pass the seal on
                print(cardStr(card), "4")
                print(cardStr(card), 4)
                print(cardStr(card), card.rank)
                print(cardStr(card), nextCard.rank)
                print(cardStr(card), nextCard.base.id)
                print(cardStr(card), nextCard.sealess)
                if card.base.id + 1 == nextCard.base.id and nextCard.seal == nil then
                    G.E_MANAGER:add_event(
                        Event({
                            trigger = 'after',
                            delay = 0.1,
                            func = function()
                                print(cardStr(card), "5")
                                nextCard:set_seal('conj_indigo', nil, false)
                                card:set_seal(nil, true, true)
                                return true
                            end
                        }))
                end

            end
        end
    end,
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