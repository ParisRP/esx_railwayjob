local ESX = exports["es_extended"]:getSharedObject()

-- Configuration des grades pour le métier de railway
function RegisterRailwayJob()
    ESX.RegisterJob('railway', {
        label = 'Railway',
        grades = {
            ['recruit'] = {
                label = 'Stagiaire',
                salary = Config.Grades[0].salary,
                skin_male = {},
                skin_female = {}
            },
            ['metro'] = {
                label = 'Conducteur Metro',
                salary = Config.Grades[1].salary,
                skin_male = {},
                skin_female = {}
            },
            ['freight'] = {
                label = 'Conducteur Fret',
                salary = Config.Grades[2].salary,
                skin_male = {},
                skin_female = {}
            },
            ['boss'] = {
                label = 'Chef de Gare',
                salary = Config.Grades[3].salary,
                skin_male = {},
                skin_female = {},
                boss = true
            }
        }
    })
end

CreateThread(function()
    RegisterRailwayJob()
end)