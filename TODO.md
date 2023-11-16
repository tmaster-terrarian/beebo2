- [ ]: not started/to do
- [-]: incomplete or doing
- [/]: cancelled, kept for posterity
- [x]\: done

- player
    - [x] physics
    - [x] better states and fix state switching clunkiness
    - [x] stat management
    - [/] merge gun with player code
    - [ ] dead state
    - [x] ledge climb
    - [x] more interesting, possibly tighter movement
    - [-] skills

- camera
    - [x] following
    - [x] application_surface fuckery
        - someone give this enby a medal

- item definitions and stat changing
    - [x] defining and referencing
    - [x] inventories; for player and enemy
    - [-] better implementation
        - first off, vague. secondly, its about half done.
    - [x] all units have the same stat properties

- modifiers
    - [ ] picker screen
        - [ ] decide whether it will be an individual object or a part of gm:
            individual
                - make it communicate well with other objects, keep confusion to a minimum
                - create and destroy instances effectively
            as a part of the gm
                - reduce confusion with other parts of the gm's code
    - [ ] make some more besides the first 2
        - lol, lmao

- gun upgrades
    - [x] upgradedefs

- buffs and debuffs
    - [x] redo entire logic
    - [?] less scope issues

- enemies
    - [x] behavior states
    - [x] stats
    - [x] teams
    - [x] leveling up
    - [-] aggro
        - pretty incomplete at the moment
    - [ ] infighting?

- menu screen
    - [ ] translations
    - [ ] run starting screen (lobby)
    - [ ] settings
    - [x] run initialization

- shop and currency
    - [-] money pickups and ui counter
        - we have money and xp, no ui, and no mechanics that utilize money yet.

- risk and reward options
    - [ ] GAMBLING AHAHHAHHAHHAA
        - but how would you do it bscit

- stages and progression
    - [-] arenas
    - [ ] bosses
    - [ ] loot
    - [ ] transitions to and from stages
    - [x] difficulty
        - stole-"inspired by" ror2

- internal structure
    - [-] more tightly controlled execution order
        - might be iffy later so unmarking done status
    - [x] more centralized
        - stats being handled by gm as well
        - avoid making gm too absurdly unreadable (maybe use methods + some comments for organization?)
        - all menu screens should part of the same system, instead of three different ones lmao
    - [x] import scribble
    - [-] pausing
        - [ ] create a better method of doing this (unless sign(global.dt) is a good enough option lole)
    - [ ] utilize injection and composition more often
    - [-] reduce the amount of for loops when it comes to item and especially buff behavior
        - an EventContext class/interface may be created to reduce this

- commands
    - [ ] bring back the commands console, with more helpful structure and format
        - one day
    - [-] port over the logging system
        - perhaps update the 

- art assets
    - [ ] backgrounds
    - [-] player character animations
        - including standard poses, skills, flinches, etc.
        - [ ] translate Gan's coolass designs into sprites
    - [-] enemies + bosses

- hud
    - [-] health bar with difference visualization
        - a concept sprite has been made
    - [ ] inventory
        - make it work for at least 2 players, with the small screen resolution (might take inspiration from MCD)

- gameplay mechanics
    - [x] waves of enemies, progression based on waves
        - [-] shop appears between every 4th and 5th wave
        - [ ] next level every x waves
        - [x] boss waves
            - just no bosses yet
    - [x] enemies level up based on waves
    - [-] gun upgrade system
        upgrade tree with points to spend
        AND/OR
        > interesting gimmick-based modules (only one can be carried at a time) <
    - [x] enemies drop money and xp
    - [ ] shop bonuses based on time spent, prices based on waves

- multiplayer???
    - [x] splitscreen cameras
        - unused
    - [/] only enable splitscreen when players are far enough away from each other
        - could be easily implemented, but it's not going to happen
