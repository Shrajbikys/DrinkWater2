//
//  Constants.swift
//  DrinkWater
//
//  Created by Alexander Lyubimov on 31.05.2024.
//

import Foundation
import SwiftUI

struct Constants {
    struct Design {
        struct Fonts {
            static let BodyTitle3Font = Font.system(size: 40)
            static let BodyTitle2Font = Font.system(size: 33)
            static let BodyTitle1Font = Font.system(size: 30)
            static let BodyLargeFont = Font.system(size: 25)
            static let BodyMainFont = Font.system(size: 20)
            static let BodyMediumFont = Font.system(size: 17)
            static let BodySmallFont = Font.system(size: 15)
            static let BodyMiniFont = Font.system(size: 12)
        }
        
        struct Colors {
            static let settingsListRowBackground = Color(#colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 0.1))
        }
    }
    
    struct Back {
        struct Reminder {
            static let nameSound = ["Без звука", "По умолчанию", "Звук 1", "Звук 2", "Звук 3", "Звук 4", "Звук 5", "Звук 6"]
            static let localizedNameSound: [String: LocalizedStringKey] = ["Без звука": "Без звука", "По умолчанию": "По умолчанию", "Звук 1": "Звук 1", "Звук 2": "Звук 2", "Звук 3": "Звук 3", "Звук 4": "Звук 4", "Звук 5": "Звук 5", "Звук 6": "Звук 6"]
            static let soundPlayArray = ["Без звука": "Sound off", "По умолчанию": "Default", "Звук 1": "Sound-1", "Звук 2": "Sound-2", "Звук 3": "Sound-3", "Звук 4": "Sound-4", "Звук 5": "Sound-5", "Звук 6": "Sound-6"]
            static let soundNameArray = ["Без звука": "Sound off", "По умолчанию": "Default", "Звук 1": "Sound-1.aiff", "Звук 2": "Sound-2.aiff", "Звук 3": "Sound-3.aiff", "Звук 4": "Sound-4.aiff", "Звук 5": "Sound-5.aiff", "Звук 6": "Sound-6.aiff"]
            
            static let nameInterval = ["30 минут", "1 час", "1 час 30 минут", "2 часа", "2 часа 30 минут", "3 часа"]
            static let localizedNameInterval: [String: LocalizedStringKey] = ["30 минут": "30 минут", "1 час": "1 час", "1 час 30 минут": "1 час 30 минут", "2 часа": "2 часа", "2 часа 30 минут": "2 часа 30 минут", "3 часа": "3 часа"]
            
            static let localizedTitleNotificationText: LocalizedStringKey = "Пора выпить воды"
            static let titleNotificationText: String.LocalizationValue = "Пора выпить воды"
            
            static let localizedBodyNotificationText: [LocalizedStringKey] = ["Не забывайте - вода улучшает пищеварение", "Не забывайте - вода улучшает состояние волос и кожи", "Не забывайте - вода способствует похудению", "Не забывайте - вода выводит из организма шлаки и токсины", "Не забывайте - вода снимает напряжение и борется с усталостью", "Не забывайте - вода способствует подавлению чувства голода", "Не забывайте - вода улучшает кровообращение", "Вода обеспечивает выработку в организме ферментов, которые сжигают жиры", "Не забывайте - вода восстанавливает водный баланс", "Не забывайте - вода нормализует обмен веществ", "Не забывайте - вода нормализует мозговую деятельность", "Стакан воды во время еды позволит насыщаться меньшими порциями", "Вода улучшает метаболизм, запускает обменные процессы"]
            static let bodyNotificationText: [String.LocalizationValue] = ["Не забывайте - вода улучшает пищеварение", "Не забывайте - вода улучшает состояние волос и кожи", "Не забывайте - вода способствует похудению", "Не забывайте - вода выводит из организма шлаки и токсины", "Не забывайте - вода снимает напряжение и борется с усталостью", "Не забывайте - вода способствует подавлению чувства голода", "Не забывайте - вода улучшает кровообращение", "Вода обеспечивает выработку в организме ферментов, которые сжигают жиры", "Не забывайте - вода восстанавливает водный баланс", "Не забывайте - вода нормализует обмен веществ", "Не забывайте - вода нормализует мозговую деятельность", "Стакан воды во время еды позволит насыщаться меньшими порциями", "Вода улучшает метаболизм, запускает обменные процессы"]
        }
        
        struct Achievement {
            static let imagesAchievement = ["1DayAchiev", "7DaysAchiev", "14DaysAchiev", "30DaysAchiev", "60DaysAchiev", "90DaysAchiev", "180DaysAchiev", "270DaysAchiev", "365DaysAchiev"]
            static let namesAchievementFirst: [LocalizedStringKey] = ["Первый день", "7 дней", "14 дней", "30 дней", "60 дней", "90 дней", "180 дней", "270 дней", "365 дней"]
            static let namesAchievementSecond: [LocalizedStringKey] = ["Начало положено!", "Смотри как легко!", "Только вперёд!", "Не останавливайся!", "Всегда стремись выше!", "Мотивация на уровне!", "Ты можешь больше!", "Всё возможно!", "Ты на вершине!"]
        }
        
        struct Purchase {
            static let purchaseTitle1: [LocalizedStringKey] = ["Трекер веса", "Достижения", "Стильные виджеты", "Дополнительные напитки", "Интеграция с Apple Health", "Выбор звука уведомлений", "Приложение для Apple Watch", "Импорт/экспорт данных в iCloud", "Поддержите нас"]
            static let purchaseTitle2: [LocalizedStringKey] = ["Следи за своим прогрессом и достигай идеального веса шаг за шагом", "Пейте воду регулярно и достигайте новых высот", "Отслеживайте показатели выпитого за день не открывая приложение", "Какао, Смузи, Йогурт и другие напитки", "Автоматическое внесение данных в Apple Health", "Добавьте индивидуальности вашему уведомлению", "Вносите информацию и следите за количеством выпитого через Apple Watch", "Перенесите все данные, до последней капли, на новое устройство", "Ваша подписка очень мотивирует нас и помогает развитию Drink Water"]
        }
        
        struct Types {
            enum Gender: String, CaseIterable, Codable {
                case girl = "Женщина"
                case man = "Мужчина"
            }
            
            enum Unit {
                case kg
                case pounds
            }
        }
    }
}

struct Drinks: Codable, Identifiable {
    let id = UUID()
    let key: String
    let name: String
    let hydration: Double

    enum CodingKeys: String, CodingKey {
        case key
        case name
        case hydration = "hydration"
    }
}
