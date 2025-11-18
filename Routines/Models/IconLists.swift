//
//  IconLists.swift
//  Routines
//
//  Created by Sam Clemente on 7/16/24.
//

import Foundation

// NOTE: You've gotten to "shuffle" in the list of SF Symbols

/// This enum is used to store all of the various names of he SF Symbols used in the icon picker to be used in `Routine.iconSymbol`. The `rawValue` is used as the label for the category in the interface. The enum also conforms to `CaseIterable` and `Identifiable` to be used in `ForEach` views in the interface. The enum also conforms to `Sequence` for testing purposes.
enum IconLists: String, CaseIterable, Identifiable, Sequence {
    case time = "Time"
    case lists = "Lists"
    case drawing = "Drawing"
    case office = "Office"
    case home = "Home"
    case arrows = "Arrows"
    case books = "Books"
    case travel = "Travel"
    case school = "School"
    case people = "People"
    case sports = "Sports"
    case sportsEquipment = "Sports Equipment"
    case symbols = "Symbols"
    case globe = "Globe"
    case weather = "Weather"
    case misc = "Misc."
    
    var id: IconLists { self }
    
    /// Required for conformance to ``Sequence``
    func makeIterator() -> IndexingIterator<[String]> {
        return iconList.makeIterator()
    }
    
    var iconList: [String] {
        switch self {
        case .time:
            return ["sun.min", "sun.max", "sun.max.trianglebadge.exclamationmark", "sunrise", "sunset", "sun.horizon", "sun.dust", "sun.haze", "sun.rain", "sun.snow", "moonphase.waxing.crescent", "moonphase.first.quarter", "moonphase.waxing.gibbous", "moonphase.full.moon", "moonphase.waning.gibbous", "moonphase.last.quarter", "moonphase.waning.crescent", "zzz", "moon", "moonrise", "moonset", "moon.dust", "moon.haze", "moon.zzz", "moon.stars", "hourglass", "calendar", "clock"]
        case .lists:
            return ["list.bullet", "list.dash", "list.triangle", "list.number", "list.star", "list.clipboard", "list.bullet.clipboard", "list.bullet.rectangle", "list.bullet.indent", "checklist.unchecked", "checklist", "checklist.checked"]
        case .drawing:
            return ["pencil", "pencil.slash", "eraser", "eraser.line.dashed", "scribble", "pencil.and.scribble", "highlighter", "pencil.and.outline", "pencil.tip", "lasso", "lasso.badge.sparkles"]
        case .office:
            return ["trash", "trash.slash", "arrow.up.trash", "folder", "questionmark.folder", "paperplane", "tray", "tray.full", "tray.and.arrow.up", "tray.and.arrow.down", "tray.2", "archivebox", "xmark.bin", "arrow.up.bin", "doc", "arrow.up.doc", "arrow.down.doc", "doc.text", "doc.zipper", "doc.on.doc", "doc.on.clipboard", "clipboard"]
        case .home:
            return ["house", "lightbulb", "lightbulb.2", "lightbulb.led", "lightbulb.led.wide", "fan", "fan.floor", "fan.ceiling", "party.popper", "frying.pan", "popcorn", "bed.double", "sofa", "chair.lounge", "fireplace", "washer", "dryer", "oven", "stove", "cooktop", "microwave", "refrigerator", "sink", "toilet"]
        case .arrows:
            return ["arrowshape.left", "arrowshape.right", "arrowshape.up", "arrowshape.down", "arrowshape.left.arrowshape.right", "arrowshape.turn.up.left", "arrowshape.turn.up.right", "arrowshape.turn.up.left.2", "arrowshape.zigzag.right", "arrowshape.bounce.right"]
        case .books:
            return ["book", "books.vertical", "book.closed", "character.book.closed", "text.book.closed", "menucard", "greetingcard", "magazine", "newspaper", "doc.text.image", "bookmark", "bookmark.slash"]
        case .travel:
            return ["airplane", "airplane.arrival", "airplane.departure", "car", "bus", "tram", "cablecar", "lightrail", "ferry", "sailboat", "bicycle", "scooter", "fuelpump", "ev.charger"]
        case .school:
            return ["graduationcap", "pencil.and.ruler", "ruler", "backpack", "studentdesk", "paperclip"]
        case .people:
            return ["person", "person.slash", "person.fill.xmark", "person.fill.questionmark", "person.badge.clock", "person.badge.shield.checkmark", "person.badge.key", "person.2.badge.key", "shared.with.you", "shared.with.you.slash", "person.and.arrow.left.and.arrow.right", "person.2", "person.2.slash", "person.2.gobackward", "person.2.badge.gearshape", "person.wave.2", "person.2.wave.2", "person.line.dotted.person", "person.3", "person.3.sequence", "person.and.background.dotted", "person.and.background.striped.horizontal", "figure.stand", "figure.stand.line.dotted.figure.stand", "figure.dress.line.vertical.figure", "figure.arms.open", "figure.2.arms.open", "figure.2.and.child.holdinghands", "figure.and.child.holdinghands", "figure", "figure.2", "figure.walk", "figure.walk.arrival", "figure.walk.departure", "figure.walk.motion", "figure.walk.motion.trianglebadge.exclamationmark", "figure.wave", "figure.fall", "figure.run", "figure.roll"]
        case .sports:
            return ["figure.roll.runningpace", "figure.run", "figure.american.football", "figure.archery", "figure.australian.football", "figure.badminton", "figure.barre", "figure.baseball", "figure.basketball", "figure.bowling", "figure.boxing", "figure.climbing", "figure.cooldown", "figure.core.training", "figure.cricket", "figure.skiing.crosscountry", "figure.cross.training", "figure.curling", "figure.dance", "figure.disc.sports", "figure.skiing.downhill", "figure.elliptical", "figure.equestrian.sports", "figure.fencing", "figure.fishing", "figure.flexibility", "figure.strengthtraining.functional", "figure.golf", "figure.gymnastics", "figure.hand.cycling", "figure.handball", "figure.highintensity.intervaltraining", "figure.hiking", "figure.hockey", "figure.hunting", "figure.indoor.cycle", "figure.jumprope", "figure.kickboxing", "figure.lacrosse", "figure.martial.arts", "figure.mind.and.body", "figure.mixed.cardio", "figure.open.water.swim", "figure.outdoor.cycle", "figure.pickleball", "figure.pilates", "figure.play", "figure.pool.swim", "figure.racquetball", "figure.rolling", "figure.rower", "figure.rugby", "figure.sailing", "figure.skating", "figure.snowboarding", "figure.soccer", "figure.socialdance", "figure.softball", "figure.squash", "figure.stair.stepper", "figure.stairs", "figure.step.training", "figure.surfing", "figure.table.tennis", "figure.taichi", "figure.tennis", "figure.track.and.field", "figure.strengthtraining.traditional", "figure.volleyball", "figure.water.fitness", "figure.waterpolo", "figure.wrestling", "figure.yoga"]
        case .sportsEquipment:
            return ["baseball.diamond.bases", "dumbbell", "sportscourt", "soccerball", "baseball", "basketball", "football", "tennis.racket", "hockey.puck", "cricket.ball", "tennisball", "volleyball", "skateboard", "skis", "snowboard", "surfboard", "gym.bag", "rosette", "trophy", "medal"]
        case .symbols:
            return ["peacesign", "globe", "network", "network.slash", "network.badge.shield.half.filled"]
        case .globe:
            return ["globe.americas", "globe.europe.africa", "globe.asia.australia", "globe.central.south.asia", "globe.desk"]
        case .weather:
            return ["cloud", "cloud.drizzle", "cloud.rain", "cloud.heavyrain", "cloud.fog", "cloud.hail", "cloud.snow", "cloud.sleet", "cloud.bolt", "cloud.bolt.rain", "cloud.sun", "cloud.sun.rain", "cloud.sun.bolt", "cloud.moon", "cloud.moon.rain", "cloud.moon.bolt", "smoke", "wind", "wind.snow", "snowflake", "tornado", "tropicalstorm", "hurricane", "thermometer.sun", "thermometer.snowflake", "thermometer.variable.and.figure", "thermometer.low", "thermometer.medium", "thermometer.high", "thermometer.medium.slash", "aqi.low", "aqi.medium", "aqi.high", "humidity", "rainbow", "cloud.rainbow.half", "drop", "drop.degreesign", "drop.degreesign.slash", "drop.triangle", "flame", "beach.umbrella", "umbrella", "umbrella.percent"]
        case .misc:
            return ["clear", "delete.left", "delete.right", "shift", "capslock", "eject", "mount", "rays", "cursorarrow.rays", "slowmo", "timelapse", "play", "play.square", "play.rectangle", "play.square.stack", "play.slash", "pause", "pause.fill", "pause.circle", "pause.rectangle", "stop", "record.circle", "playpause", "playpause.fill", "backward", "forward", "backward.end", "forward.end", "backward.end.alt", "forward.end.alt", "backward.frame", "forward.frame"]
        }
    }
}
