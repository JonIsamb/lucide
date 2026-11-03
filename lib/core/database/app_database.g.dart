// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$InstrumentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $InstrumentsTable get instruments => attachedDatabase.instruments;
  InstrumentsDaoManager get managers => InstrumentsDaoManager(this);
}

class InstrumentsDaoManager {
  final _$InstrumentsDaoMixin _db;
  InstrumentsDaoManager(this._db);
  $$InstrumentsTableTableManager get instruments =>
      $$InstrumentsTableTableManager(_db.attachedDatabase, _db.instruments);
}

mixin _$FavoritesDaoMixin on DatabaseAccessor<AppDatabase> {
  $FavoritesTable get favorites => attachedDatabase.favorites;
  FavoritesDaoManager get managers => FavoritesDaoManager(this);
}

class FavoritesDaoManager {
  final _$FavoritesDaoMixin _db;
  FavoritesDaoManager(this._db);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db.attachedDatabase, _db.favorites);
}

mixin _$CandlesDaoMixin on DatabaseAccessor<AppDatabase> {
  $WeeklyCandlesTable get weeklyCandles => attachedDatabase.weeklyCandles;
  CandlesDaoManager get managers => CandlesDaoManager(this);
}

class CandlesDaoManager {
  final _$CandlesDaoMixin _db;
  CandlesDaoManager(this._db);
  $$WeeklyCandlesTableTableManager get weeklyCandles =>
      $$WeeklyCandlesTableTableManager(_db.attachedDatabase, _db.weeklyCandles);
}

mixin _$CacheMetaDaoMixin on DatabaseAccessor<AppDatabase> {
  $CacheMetaTable get cacheMeta => attachedDatabase.cacheMeta;
  CacheMetaDaoManager get managers => CacheMetaDaoManager(this);
}

class CacheMetaDaoManager {
  final _$CacheMetaDaoMixin _db;
  CacheMetaDaoManager(this._db);
  $$CacheMetaTableTableManager get cacheMeta =>
      $$CacheMetaTableTableManager(_db.attachedDatabase, _db.cacheMeta);
}

mixin _$FxRatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $FxRatesTable get fxRates => attachedDatabase.fxRates;
  FxRatesDaoManager get managers => FxRatesDaoManager(this);
}

class FxRatesDaoManager {
  final _$FxRatesDaoMixin _db;
  FxRatesDaoManager(this._db);
  $$FxRatesTableTableManager get fxRates =>
      $$FxRatesTableTableManager(_db.attachedDatabase, _db.fxRates);
}

mixin _$InflationDaoMixin on DatabaseAccessor<AppDatabase> {
  $InflationRatesTable get inflationRates => attachedDatabase.inflationRates;
  InflationDaoManager get managers => InflationDaoManager(this);
}

class InflationDaoManager {
  final _$InflationDaoMixin _db;
  InflationDaoManager(this._db);
  $$InflationRatesTableTableManager get inflationRates =>
      $$InflationRatesTableTableManager(
        _db.attachedDatabase,
        _db.inflationRates,
      );
}

mixin _$SimulationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SimulationsTable get simulations => attachedDatabase.simulations;
  SimulationsDaoManager get managers => SimulationsDaoManager(this);
}

class SimulationsDaoManager {
  final _$SimulationsDaoMixin _db;
  SimulationsDaoManager(this._db);
  $$SimulationsTableTableManager get simulations =>
      $$SimulationsTableTableManager(_db.attachedDatabase, _db.simulations);
}

class $InstrumentsTable extends Instruments
    with TableInfo<$InstrumentsTable, InstrumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstrumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exchangeMeta = const VerificationMeta(
    'exchange',
  );
  @override
  late final GeneratedColumn<String> exchange = GeneratedColumn<String>(
    'exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peaEligibleMeta = const VerificationMeta(
    'peaEligible',
  );
  @override
  late final GeneratedColumn<bool> peaEligible = GeneratedColumn<bool>(
    'pea_eligible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pea_eligible" IN (0, 1))',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    name,
    type,
    currency,
    exchange,
    peaEligible,
    description,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instruments';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstrumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('exchange')) {
      context.handle(
        _exchangeMeta,
        exchange.isAcceptableOrUnknown(data['exchange']!, _exchangeMeta),
      );
    }
    if (data.containsKey('pea_eligible')) {
      context.handle(
        _peaEligibleMeta,
        peaEligible.isAcceptableOrUnknown(
          data['pea_eligible']!,
          _peaEligibleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peaEligibleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  InstrumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstrumentRow(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      exchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exchange'],
      ),
      peaEligible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pea_eligible'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $InstrumentsTable createAlias(String alias) {
    return $InstrumentsTable(attachedDatabase, alias);
  }
}

class InstrumentRow extends DataClass implements Insertable<InstrumentRow> {
  final String symbol;
  final String name;

  /// "stock", "etf" or "crypto".
  final String type;
  final String currency;
  final String? exchange;
  final bool peaEligible;
  final String description;

  /// Order of the asset in catalog.json, used to load prices in that order.
  final int position;
  const InstrumentRow({
    required this.symbol,
    required this.name,
    required this.type,
    required this.currency,
    this.exchange,
    required this.peaEligible,
    required this.description,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || exchange != null) {
      map['exchange'] = Variable<String>(exchange);
    }
    map['pea_eligible'] = Variable<bool>(peaEligible);
    map['description'] = Variable<String>(description);
    map['position'] = Variable<int>(position);
    return map;
  }

  InstrumentsCompanion toCompanion(bool nullToAbsent) {
    return InstrumentsCompanion(
      symbol: Value(symbol),
      name: Value(name),
      type: Value(type),
      currency: Value(currency),
      exchange: exchange == null && nullToAbsent
          ? const Value.absent()
          : Value(exchange),
      peaEligible: Value(peaEligible),
      description: Value(description),
      position: Value(position),
    );
  }

  factory InstrumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstrumentRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      currency: serializer.fromJson<String>(json['currency']),
      exchange: serializer.fromJson<String?>(json['exchange']),
      peaEligible: serializer.fromJson<bool>(json['peaEligible']),
      description: serializer.fromJson<String>(json['description']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'currency': serializer.toJson<String>(currency),
      'exchange': serializer.toJson<String?>(exchange),
      'peaEligible': serializer.toJson<bool>(peaEligible),
      'description': serializer.toJson<String>(description),
      'position': serializer.toJson<int>(position),
    };
  }

  InstrumentRow copyWith({
    String? symbol,
    String? name,
    String? type,
    String? currency,
    Value<String?> exchange = const Value.absent(),
    bool? peaEligible,
    String? description,
    int? position,
  }) => InstrumentRow(
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    exchange: exchange.present ? exchange.value : this.exchange,
    peaEligible: peaEligible ?? this.peaEligible,
    description: description ?? this.description,
    position: position ?? this.position,
  );
  InstrumentRow copyWithCompanion(InstrumentsCompanion data) {
    return InstrumentRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      exchange: data.exchange.present ? data.exchange.value : this.exchange,
      peaEligible: data.peaEligible.present
          ? data.peaEligible.value
          : this.peaEligible,
      description: data.description.present
          ? data.description.value
          : this.description,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentRow(')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('exchange: $exchange, ')
          ..write('peaEligible: $peaEligible, ')
          ..write('description: $description, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    symbol,
    name,
    type,
    currency,
    exchange,
    peaEligible,
    description,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstrumentRow &&
          other.symbol == this.symbol &&
          other.name == this.name &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.exchange == this.exchange &&
          other.peaEligible == this.peaEligible &&
          other.description == this.description &&
          other.position == this.position);
}

class InstrumentsCompanion extends UpdateCompanion<InstrumentRow> {
  final Value<String> symbol;
  final Value<String> name;
  final Value<String> type;
  final Value<String> currency;
  final Value<String?> exchange;
  final Value<bool> peaEligible;
  final Value<String> description;
  final Value<int> position;
  final Value<int> rowid;
  const InstrumentsCompanion({
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.exchange = const Value.absent(),
    this.peaEligible = const Value.absent(),
    this.description = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstrumentsCompanion.insert({
    required String symbol,
    required String name,
    required String type,
    required String currency,
    this.exchange = const Value.absent(),
    required bool peaEligible,
    required String description,
    required int position,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       name = Value(name),
       type = Value(type),
       currency = Value(currency),
       peaEligible = Value(peaEligible),
       description = Value(description),
       position = Value(position);
  static Insertable<InstrumentRow> custom({
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<String>? exchange,
    Expression<bool>? peaEligible,
    Expression<String>? description,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (exchange != null) 'exchange': exchange,
      if (peaEligible != null) 'pea_eligible': peaEligible,
      if (description != null) 'description': description,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstrumentsCompanion copyWith({
    Value<String>? symbol,
    Value<String>? name,
    Value<String>? type,
    Value<String>? currency,
    Value<String?>? exchange,
    Value<bool>? peaEligible,
    Value<String>? description,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return InstrumentsCompanion(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      exchange: exchange ?? this.exchange,
      peaEligible: peaEligible ?? this.peaEligible,
      description: description ?? this.description,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (exchange.present) {
      map['exchange'] = Variable<String>(exchange.value);
    }
    if (peaEligible.present) {
      map['pea_eligible'] = Variable<bool>(peaEligible.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentsCompanion(')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('exchange: $exchange, ')
          ..write('peaEligible: $peaEligible, ')
          ..write('description: $description, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeeklyCandlesTable extends WeeklyCandles
    with TableInfo<$WeeklyCandlesTable, CandleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyCandlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openMeta = const VerificationMeta('open');
  @override
  late final GeneratedColumn<double> open = GeneratedColumn<double>(
    'open',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _highMeta = const VerificationMeta('high');
  @override
  late final GeneratedColumn<double> high = GeneratedColumn<double>(
    'high',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lowMeta = const VerificationMeta('low');
  @override
  late final GeneratedColumn<double> low = GeneratedColumn<double>(
    'low',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closeMeta = const VerificationMeta('close');
  @override
  late final GeneratedColumn<double> close = GeneratedColumn<double>(
    'close',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
    'volume',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    date,
    open,
    high,
    low,
    close,
    volume,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_candles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CandleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('open')) {
      context.handle(
        _openMeta,
        open.isAcceptableOrUnknown(data['open']!, _openMeta),
      );
    } else if (isInserting) {
      context.missing(_openMeta);
    }
    if (data.containsKey('high')) {
      context.handle(
        _highMeta,
        high.isAcceptableOrUnknown(data['high']!, _highMeta),
      );
    } else if (isInserting) {
      context.missing(_highMeta);
    }
    if (data.containsKey('low')) {
      context.handle(
        _lowMeta,
        low.isAcceptableOrUnknown(data['low']!, _lowMeta),
      );
    } else if (isInserting) {
      context.missing(_lowMeta);
    }
    if (data.containsKey('close')) {
      context.handle(
        _closeMeta,
        close.isAcceptableOrUnknown(data['close']!, _closeMeta),
      );
    } else if (isInserting) {
      context.missing(_closeMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol, date};
  @override
  CandleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CandleRow(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      open: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}open'],
      )!,
      high: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}high'],
      )!,
      low: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}low'],
      )!,
      close: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}close'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volume'],
      ),
    );
  }

  @override
  $WeeklyCandlesTable createAlias(String alias) {
    return $WeeklyCandlesTable(attachedDatabase, alias);
  }
}

class CandleRow extends DataClass implements Insertable<CandleRow> {
  final String symbol;
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;
  const CandleRow({
    required this.symbol,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['date'] = Variable<DateTime>(date);
    map['open'] = Variable<double>(open);
    map['high'] = Variable<double>(high);
    map['low'] = Variable<double>(low);
    map['close'] = Variable<double>(close);
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<double>(volume);
    }
    return map;
  }

  WeeklyCandlesCompanion toCompanion(bool nullToAbsent) {
    return WeeklyCandlesCompanion(
      symbol: Value(symbol),
      date: Value(date),
      open: Value(open),
      high: Value(high),
      low: Value(low),
      close: Value(close),
      volume: volume == null && nullToAbsent
          ? const Value.absent()
          : Value(volume),
    );
  }

  factory CandleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CandleRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      date: serializer.fromJson<DateTime>(json['date']),
      open: serializer.fromJson<double>(json['open']),
      high: serializer.fromJson<double>(json['high']),
      low: serializer.fromJson<double>(json['low']),
      close: serializer.fromJson<double>(json['close']),
      volume: serializer.fromJson<double?>(json['volume']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'date': serializer.toJson<DateTime>(date),
      'open': serializer.toJson<double>(open),
      'high': serializer.toJson<double>(high),
      'low': serializer.toJson<double>(low),
      'close': serializer.toJson<double>(close),
      'volume': serializer.toJson<double?>(volume),
    };
  }

  CandleRow copyWith({
    String? symbol,
    DateTime? date,
    double? open,
    double? high,
    double? low,
    double? close,
    Value<double?> volume = const Value.absent(),
  }) => CandleRow(
    symbol: symbol ?? this.symbol,
    date: date ?? this.date,
    open: open ?? this.open,
    high: high ?? this.high,
    low: low ?? this.low,
    close: close ?? this.close,
    volume: volume.present ? volume.value : this.volume,
  );
  CandleRow copyWithCompanion(WeeklyCandlesCompanion data) {
    return CandleRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      date: data.date.present ? data.date.value : this.date,
      open: data.open.present ? data.open.value : this.open,
      high: data.high.present ? data.high.value : this.high,
      low: data.low.present ? data.low.value : this.low,
      close: data.close.present ? data.close.value : this.close,
      volume: data.volume.present ? data.volume.value : this.volume,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CandleRow(')
          ..write('symbol: $symbol, ')
          ..write('date: $date, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(symbol, date, open, high, low, close, volume);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CandleRow &&
          other.symbol == this.symbol &&
          other.date == this.date &&
          other.open == this.open &&
          other.high == this.high &&
          other.low == this.low &&
          other.close == this.close &&
          other.volume == this.volume);
}

class WeeklyCandlesCompanion extends UpdateCompanion<CandleRow> {
  final Value<String> symbol;
  final Value<DateTime> date;
  final Value<double> open;
  final Value<double> high;
  final Value<double> low;
  final Value<double> close;
  final Value<double?> volume;
  final Value<int> rowid;
  const WeeklyCandlesCompanion({
    this.symbol = const Value.absent(),
    this.date = const Value.absent(),
    this.open = const Value.absent(),
    this.high = const Value.absent(),
    this.low = const Value.absent(),
    this.close = const Value.absent(),
    this.volume = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeeklyCandlesCompanion.insert({
    required String symbol,
    required DateTime date,
    required double open,
    required double high,
    required double low,
    required double close,
    this.volume = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       date = Value(date),
       open = Value(open),
       high = Value(high),
       low = Value(low),
       close = Value(close);
  static Insertable<CandleRow> custom({
    Expression<String>? symbol,
    Expression<DateTime>? date,
    Expression<double>? open,
    Expression<double>? high,
    Expression<double>? low,
    Expression<double>? close,
    Expression<double>? volume,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (date != null) 'date': date,
      if (open != null) 'open': open,
      if (high != null) 'high': high,
      if (low != null) 'low': low,
      if (close != null) 'close': close,
      if (volume != null) 'volume': volume,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeeklyCandlesCompanion copyWith({
    Value<String>? symbol,
    Value<DateTime>? date,
    Value<double>? open,
    Value<double>? high,
    Value<double>? low,
    Value<double>? close,
    Value<double?>? volume,
    Value<int>? rowid,
  }) {
    return WeeklyCandlesCompanion(
      symbol: symbol ?? this.symbol,
      date: date ?? this.date,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (open.present) {
      map['open'] = Variable<double>(open.value);
    }
    if (high.present) {
      map['high'] = Variable<double>(high.value);
    }
    if (low.present) {
      map['low'] = Variable<double>(low.value);
    }
    if (close.present) {
      map['close'] = Variable<double>(close.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyCandlesCompanion(')
          ..write('symbol: $symbol, ')
          ..write('date: $date, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [symbol, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final String symbol;
  final DateTime addedAt;
  const FavoriteRow({required this.symbol, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(symbol: Value(symbol), addedAt: Value(addedAt));
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  FavoriteRow copyWith({String? symbol, DateTime? addedAt}) => FavoriteRow(
    symbol: symbol ?? this.symbol,
    addedAt: addedAt ?? this.addedAt,
  );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('symbol: $symbol, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(symbol, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.symbol == this.symbol &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<String> symbol;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.symbol = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String symbol,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       addedAt = Value(addedAt);
  static Insertable<FavoriteRow> custom({
    Expression<String>? symbol,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? symbol,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      symbol: symbol ?? this.symbol,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('symbol: $symbol, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheMetaTable extends CacheMeta
    with TableInfo<$CacheMetaTable, CacheMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastFetchedAtMeta = const VerificationMeta(
    'lastFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetchedAt =
      GeneratedColumn<DateTime>(
        'last_fetched_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [symbol, lastFetchedAt, logoUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('last_fetched_at')) {
      context.handle(
        _lastFetchedAtMeta,
        lastFetchedAt.isAcceptableOrUnknown(
          data['last_fetched_at']!,
          _lastFetchedAtMeta,
        ),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  CacheMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheMetaRow(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      lastFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched_at'],
      ),
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
    );
  }

  @override
  $CacheMetaTable createAlias(String alias) {
    return $CacheMetaTable(attachedDatabase, alias);
  }
}

class CacheMetaRow extends DataClass implements Insertable<CacheMetaRow> {
  final String symbol;

  /// Last successful download of the series. Null: never downloaded.
  final DateTime? lastFetchedAt;

  /// Null: never asked. Empty string: asked, Twelve Data has no logo, so
  /// we never ask again (it would waste a credit).
  final String? logoUrl;
  const CacheMetaRow({required this.symbol, this.lastFetchedAt, this.logoUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    if (!nullToAbsent || lastFetchedAt != null) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt);
    }
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    return map;
  }

  CacheMetaCompanion toCompanion(bool nullToAbsent) {
    return CacheMetaCompanion(
      symbol: Value(symbol),
      lastFetchedAt: lastFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetchedAt),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
    );
  }

  factory CacheMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheMetaRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      lastFetchedAt: serializer.fromJson<DateTime?>(json['lastFetchedAt']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'lastFetchedAt': serializer.toJson<DateTime?>(lastFetchedAt),
      'logoUrl': serializer.toJson<String?>(logoUrl),
    };
  }

  CacheMetaRow copyWith({
    String? symbol,
    Value<DateTime?> lastFetchedAt = const Value.absent(),
    Value<String?> logoUrl = const Value.absent(),
  }) => CacheMetaRow(
    symbol: symbol ?? this.symbol,
    lastFetchedAt: lastFetchedAt.present
        ? lastFetchedAt.value
        : this.lastFetchedAt,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
  );
  CacheMetaRow copyWithCompanion(CacheMetaCompanion data) {
    return CacheMetaRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      lastFetchedAt: data.lastFetchedAt.present
          ? data.lastFetchedAt.value
          : this.lastFetchedAt,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetaRow(')
          ..write('symbol: $symbol, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('logoUrl: $logoUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(symbol, lastFetchedAt, logoUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheMetaRow &&
          other.symbol == this.symbol &&
          other.lastFetchedAt == this.lastFetchedAt &&
          other.logoUrl == this.logoUrl);
}

class CacheMetaCompanion extends UpdateCompanion<CacheMetaRow> {
  final Value<String> symbol;
  final Value<DateTime?> lastFetchedAt;
  final Value<String?> logoUrl;
  final Value<int> rowid;
  const CacheMetaCompanion({
    this.symbol = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMetaCompanion.insert({
    required String symbol,
    this.lastFetchedAt = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol);
  static Insertable<CacheMetaRow> custom({
    Expression<String>? symbol,
    Expression<DateTime>? lastFetchedAt,
    Expression<String>? logoUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (lastFetchedAt != null) 'last_fetched_at': lastFetchedAt,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheMetaCompanion copyWith({
    Value<String>? symbol,
    Value<DateTime?>? lastFetchedAt,
    Value<String?>? logoUrl,
    Value<int>? rowid,
  }) {
    return CacheMetaCompanion(
      symbol: symbol ?? this.symbol,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      logoUrl: logoUrl ?? this.logoUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (lastFetchedAt.present) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetaCompanion(')
          ..write('symbol: $symbol, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FxRatesTable extends FxRates with TableInfo<$FxRatesTable, FxRateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eurUsdMeta = const VerificationMeta('eurUsd');
  @override
  late final GeneratedColumn<double> eurUsd = GeneratedColumn<double>(
    'eur_usd',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, eurUsd];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fx_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<FxRateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('eur_usd')) {
      context.handle(
        _eurUsdMeta,
        eurUsd.isAcceptableOrUnknown(data['eur_usd']!, _eurUsdMeta),
      );
    } else if (isInserting) {
      context.missing(_eurUsdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  FxRateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FxRateRow(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      eurUsd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}eur_usd'],
      )!,
    );
  }

  @override
  $FxRatesTable createAlias(String alias) {
    return $FxRatesTable(attachedDatabase, alias);
  }
}

class FxRateRow extends DataClass implements Insertable<FxRateRow> {
  final String day;
  final double eurUsd;
  const FxRateRow({required this.day, required this.eurUsd});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['eur_usd'] = Variable<double>(eurUsd);
    return map;
  }

  FxRatesCompanion toCompanion(bool nullToAbsent) {
    return FxRatesCompanion(day: Value(day), eurUsd: Value(eurUsd));
  }

  factory FxRateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FxRateRow(
      day: serializer.fromJson<String>(json['day']),
      eurUsd: serializer.fromJson<double>(json['eurUsd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'eurUsd': serializer.toJson<double>(eurUsd),
    };
  }

  FxRateRow copyWith({String? day, double? eurUsd}) =>
      FxRateRow(day: day ?? this.day, eurUsd: eurUsd ?? this.eurUsd);
  FxRateRow copyWithCompanion(FxRatesCompanion data) {
    return FxRateRow(
      day: data.day.present ? data.day.value : this.day,
      eurUsd: data.eurUsd.present ? data.eurUsd.value : this.eurUsd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FxRateRow(')
          ..write('day: $day, ')
          ..write('eurUsd: $eurUsd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, eurUsd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FxRateRow &&
          other.day == this.day &&
          other.eurUsd == this.eurUsd);
}

class FxRatesCompanion extends UpdateCompanion<FxRateRow> {
  final Value<String> day;
  final Value<double> eurUsd;
  final Value<int> rowid;
  const FxRatesCompanion({
    this.day = const Value.absent(),
    this.eurUsd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FxRatesCompanion.insert({
    required String day,
    required double eurUsd,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       eurUsd = Value(eurUsd);
  static Insertable<FxRateRow> custom({
    Expression<String>? day,
    Expression<double>? eurUsd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (eurUsd != null) 'eur_usd': eurUsd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FxRatesCompanion copyWith({
    Value<String>? day,
    Value<double>? eurUsd,
    Value<int>? rowid,
  }) {
    return FxRatesCompanion(
      day: day ?? this.day,
      eurUsd: eurUsd ?? this.eurUsd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (eurUsd.present) {
      map['eur_usd'] = Variable<double>(eurUsd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FxRatesCompanion(')
          ..write('day: $day, ')
          ..write('eurUsd: $eurUsd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InflationRatesTable extends InflationRates
    with TableInfo<$InflationRatesTable, InflationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InflationRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [year, rate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inflation_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<InflationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {year};
  @override
  InflationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InflationRow(
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
    );
  }

  @override
  $InflationRatesTable createAlias(String alias) {
    return $InflationRatesTable(attachedDatabase, alias);
  }
}

class InflationRow extends DataClass implements Insertable<InflationRow> {
  final int year;
  final double rate;
  const InflationRow({required this.year, required this.rate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['year'] = Variable<int>(year);
    map['rate'] = Variable<double>(rate);
    return map;
  }

  InflationRatesCompanion toCompanion(bool nullToAbsent) {
    return InflationRatesCompanion(year: Value(year), rate: Value(rate));
  }

  factory InflationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InflationRow(
      year: serializer.fromJson<int>(json['year']),
      rate: serializer.fromJson<double>(json['rate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'year': serializer.toJson<int>(year),
      'rate': serializer.toJson<double>(rate),
    };
  }

  InflationRow copyWith({int? year, double? rate}) =>
      InflationRow(year: year ?? this.year, rate: rate ?? this.rate);
  InflationRow copyWithCompanion(InflationRatesCompanion data) {
    return InflationRow(
      year: data.year.present ? data.year.value : this.year,
      rate: data.rate.present ? data.rate.value : this.rate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InflationRow(')
          ..write('year: $year, ')
          ..write('rate: $rate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(year, rate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InflationRow &&
          other.year == this.year &&
          other.rate == this.rate);
}

class InflationRatesCompanion extends UpdateCompanion<InflationRow> {
  final Value<int> year;
  final Value<double> rate;
  const InflationRatesCompanion({
    this.year = const Value.absent(),
    this.rate = const Value.absent(),
  });
  InflationRatesCompanion.insert({
    this.year = const Value.absent(),
    required double rate,
  }) : rate = Value(rate);
  static Insertable<InflationRow> custom({
    Expression<int>? year,
    Expression<double>? rate,
  }) {
    return RawValuesInsertable({
      if (year != null) 'year': year,
      if (rate != null) 'rate': rate,
    });
  }

  InflationRatesCompanion copyWith({Value<int>? year, Value<double>? rate}) {
    return InflationRatesCompanion(
      year: year ?? this.year,
      rate: rate ?? this.rate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InflationRatesCompanion(')
          ..write('year: $year, ')
          ..write('rate: $rate')
          ..write(')'))
        .toString();
  }
}

class $SimulationsTable extends Simulations
    with TableInfo<$SimulationsTable, SimulationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimulationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetNameMeta = const VerificationMeta(
    'assetName',
  );
  @override
  late final GeneratedColumn<String> assetName = GeneratedColumn<String>(
    'asset_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsJsonMeta = const VerificationMeta(
    'paramsJson',
  );
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
    'params_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    symbol,
    assetName,
    paramsJson,
    resultJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'simulations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SimulationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('asset_name')) {
      context.handle(
        _assetNameMeta,
        assetName.isAcceptableOrUnknown(data['asset_name']!, _assetNameMeta),
      );
    } else if (isInserting) {
      context.missing(_assetNameMeta);
    }
    if (data.containsKey('params_json')) {
      context.handle(
        _paramsJsonMeta,
        paramsJson.isAcceptableOrUnknown(data['params_json']!, _paramsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_paramsJsonMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_resultJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SimulationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SimulationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      assetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_name'],
      )!,
      paramsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params_json'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SimulationsTable createAlias(String alias) {
    return $SimulationsTable(attachedDatabase, alias);
  }
}

class SimulationRow extends DataClass implements Insertable<SimulationRow> {
  final int id;
  final String symbol;
  final String assetName;
  final String paramsJson;
  final String resultJson;
  final DateTime createdAt;
  const SimulationRow({
    required this.id,
    required this.symbol,
    required this.assetName,
    required this.paramsJson,
    required this.resultJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['symbol'] = Variable<String>(symbol);
    map['asset_name'] = Variable<String>(assetName);
    map['params_json'] = Variable<String>(paramsJson);
    map['result_json'] = Variable<String>(resultJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SimulationsCompanion toCompanion(bool nullToAbsent) {
    return SimulationsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      assetName: Value(assetName),
      paramsJson: Value(paramsJson),
      resultJson: Value(resultJson),
      createdAt: Value(createdAt),
    );
  }

  factory SimulationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SimulationRow(
      id: serializer.fromJson<int>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      assetName: serializer.fromJson<String>(json['assetName']),
      paramsJson: serializer.fromJson<String>(json['paramsJson']),
      resultJson: serializer.fromJson<String>(json['resultJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'symbol': serializer.toJson<String>(symbol),
      'assetName': serializer.toJson<String>(assetName),
      'paramsJson': serializer.toJson<String>(paramsJson),
      'resultJson': serializer.toJson<String>(resultJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SimulationRow copyWith({
    int? id,
    String? symbol,
    String? assetName,
    String? paramsJson,
    String? resultJson,
    DateTime? createdAt,
  }) => SimulationRow(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    assetName: assetName ?? this.assetName,
    paramsJson: paramsJson ?? this.paramsJson,
    resultJson: resultJson ?? this.resultJson,
    createdAt: createdAt ?? this.createdAt,
  );
  SimulationRow copyWithCompanion(SimulationsCompanion data) {
    return SimulationRow(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      assetName: data.assetName.present ? data.assetName.value : this.assetName,
      paramsJson: data.paramsJson.present
          ? data.paramsJson.value
          : this.paramsJson,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SimulationRow(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('assetName: $assetName, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('resultJson: $resultJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, symbol, assetName, paramsJson, resultJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimulationRow &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.assetName == this.assetName &&
          other.paramsJson == this.paramsJson &&
          other.resultJson == this.resultJson &&
          other.createdAt == this.createdAt);
}

class SimulationsCompanion extends UpdateCompanion<SimulationRow> {
  final Value<int> id;
  final Value<String> symbol;
  final Value<String> assetName;
  final Value<String> paramsJson;
  final Value<String> resultJson;
  final Value<DateTime> createdAt;
  const SimulationsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.assetName = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SimulationsCompanion.insert({
    this.id = const Value.absent(),
    required String symbol,
    required String assetName,
    required String paramsJson,
    required String resultJson,
    required DateTime createdAt,
  }) : symbol = Value(symbol),
       assetName = Value(assetName),
       paramsJson = Value(paramsJson),
       resultJson = Value(resultJson),
       createdAt = Value(createdAt);
  static Insertable<SimulationRow> custom({
    Expression<int>? id,
    Expression<String>? symbol,
    Expression<String>? assetName,
    Expression<String>? paramsJson,
    Expression<String>? resultJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (assetName != null) 'asset_name': assetName,
      if (paramsJson != null) 'params_json': paramsJson,
      if (resultJson != null) 'result_json': resultJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SimulationsCompanion copyWith({
    Value<int>? id,
    Value<String>? symbol,
    Value<String>? assetName,
    Value<String>? paramsJson,
    Value<String>? resultJson,
    Value<DateTime>? createdAt,
  }) {
    return SimulationsCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      assetName: assetName ?? this.assetName,
      paramsJson: paramsJson ?? this.paramsJson,
      resultJson: resultJson ?? this.resultJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (assetName.present) {
      map['asset_name'] = Variable<String>(assetName.value);
    }
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SimulationsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('assetName: $assetName, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('resultJson: $resultJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InstrumentsTable instruments = $InstrumentsTable(this);
  late final $WeeklyCandlesTable weeklyCandles = $WeeklyCandlesTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $CacheMetaTable cacheMeta = $CacheMetaTable(this);
  late final $FxRatesTable fxRates = $FxRatesTable(this);
  late final $InflationRatesTable inflationRates = $InflationRatesTable(this);
  late final $SimulationsTable simulations = $SimulationsTable(this);
  late final InstrumentsDao instrumentsDao = InstrumentsDao(
    this as AppDatabase,
  );
  late final FavoritesDao favoritesDao = FavoritesDao(this as AppDatabase);
  late final CandlesDao candlesDao = CandlesDao(this as AppDatabase);
  late final CacheMetaDao cacheMetaDao = CacheMetaDao(this as AppDatabase);
  late final FxRatesDao fxRatesDao = FxRatesDao(this as AppDatabase);
  late final InflationDao inflationDao = InflationDao(this as AppDatabase);
  late final SimulationsDao simulationsDao = SimulationsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    instruments,
    weeklyCandles,
    favorites,
    cacheMeta,
    fxRates,
    inflationRates,
    simulations,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$InstrumentsTableCreateCompanionBuilder =
    InstrumentsCompanion Function({
      required String symbol,
      required String name,
      required String type,
      required String currency,
      Value<String?> exchange,
      required bool peaEligible,
      required String description,
      required int position,
      Value<int> rowid,
    });
typedef $$InstrumentsTableUpdateCompanionBuilder =
    InstrumentsCompanion Function({
      Value<String> symbol,
      Value<String> name,
      Value<String> type,
      Value<String> currency,
      Value<String?> exchange,
      Value<bool> peaEligible,
      Value<String> description,
      Value<int> position,
      Value<int> rowid,
    });

class $$InstrumentsTableFilterComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get peaEligible => $composableBuilder(
    column: $table.peaEligible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstrumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get peaEligible => $composableBuilder(
    column: $table.peaEligible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstrumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get exchange =>
      $composableBuilder(column: $table.exchange, builder: (column) => column);

  GeneratedColumn<bool> get peaEligible => $composableBuilder(
    column: $table.peaEligible,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$InstrumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstrumentsTable,
          InstrumentRow,
          $$InstrumentsTableFilterComposer,
          $$InstrumentsTableOrderingComposer,
          $$InstrumentsTableAnnotationComposer,
          $$InstrumentsTableCreateCompanionBuilder,
          $$InstrumentsTableUpdateCompanionBuilder,
          (
            InstrumentRow,
            BaseReferences<_$AppDatabase, $InstrumentsTable, InstrumentRow>,
          ),
          InstrumentRow,
          PrefetchHooks Function()
        > {
  $$InstrumentsTableTableManager(_$AppDatabase db, $InstrumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstrumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstrumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstrumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> exchange = const Value.absent(),
                Value<bool> peaEligible = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion(
                symbol: symbol,
                name: name,
                type: type,
                currency: currency,
                exchange: exchange,
                peaEligible: peaEligible,
                description: description,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required String name,
                required String type,
                required String currency,
                Value<String?> exchange = const Value.absent(),
                required bool peaEligible,
                required String description,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion.insert(
                symbol: symbol,
                name: name,
                type: type,
                currency: currency,
                exchange: exchange,
                peaEligible: peaEligible,
                description: description,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InstrumentsTable, InstrumentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InstrumentsTable,
                    InstrumentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstrumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstrumentsTable,
      InstrumentRow,
      $$InstrumentsTableFilterComposer,
      $$InstrumentsTableOrderingComposer,
      $$InstrumentsTableAnnotationComposer,
      $$InstrumentsTableCreateCompanionBuilder,
      $$InstrumentsTableUpdateCompanionBuilder,
      (
        InstrumentRow,
        BaseReferences<_$AppDatabase, $InstrumentsTable, InstrumentRow>,
      ),
      InstrumentRow,
      PrefetchHooks Function()
    >;
typedef $$WeeklyCandlesTableCreateCompanionBuilder =
    WeeklyCandlesCompanion Function({
      required String symbol,
      required DateTime date,
      required double open,
      required double high,
      required double low,
      required double close,
      Value<double?> volume,
      Value<int> rowid,
    });
typedef $$WeeklyCandlesTableUpdateCompanionBuilder =
    WeeklyCandlesCompanion Function({
      Value<String> symbol,
      Value<DateTime> date,
      Value<double> open,
      Value<double> high,
      Value<double> low,
      Value<double> close,
      Value<double?> volume,
      Value<int> rowid,
    });

class $$WeeklyCandlesTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyCandlesTable> {
  $$WeeklyCandlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get open => $composableBuilder(
    column: $table.open,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get high => $composableBuilder(
    column: $table.high,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get low => $composableBuilder(
    column: $table.low,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get close => $composableBuilder(
    column: $table.close,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklyCandlesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyCandlesTable> {
  $$WeeklyCandlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get open => $composableBuilder(
    column: $table.open,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get high => $composableBuilder(
    column: $table.high,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get low => $composableBuilder(
    column: $table.low,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get close => $composableBuilder(
    column: $table.close,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyCandlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyCandlesTable> {
  $$WeeklyCandlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get open =>
      $composableBuilder(column: $table.open, builder: (column) => column);

  GeneratedColumn<double> get high =>
      $composableBuilder(column: $table.high, builder: (column) => column);

  GeneratedColumn<double> get low =>
      $composableBuilder(column: $table.low, builder: (column) => column);

  GeneratedColumn<double> get close =>
      $composableBuilder(column: $table.close, builder: (column) => column);

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);
}

class $$WeeklyCandlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyCandlesTable,
          CandleRow,
          $$WeeklyCandlesTableFilterComposer,
          $$WeeklyCandlesTableOrderingComposer,
          $$WeeklyCandlesTableAnnotationComposer,
          $$WeeklyCandlesTableCreateCompanionBuilder,
          $$WeeklyCandlesTableUpdateCompanionBuilder,
          (
            CandleRow,
            BaseReferences<_$AppDatabase, $WeeklyCandlesTable, CandleRow>,
          ),
          CandleRow,
          PrefetchHooks Function()
        > {
  $$WeeklyCandlesTableTableManager(_$AppDatabase db, $WeeklyCandlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyCandlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyCandlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyCandlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> open = const Value.absent(),
                Value<double> high = const Value.absent(),
                Value<double> low = const Value.absent(),
                Value<double> close = const Value.absent(),
                Value<double?> volume = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeeklyCandlesCompanion(
                symbol: symbol,
                date: date,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required DateTime date,
                required double open,
                required double high,
                required double low,
                required double close,
                Value<double?> volume = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeeklyCandlesCompanion.insert(
                symbol: symbol,
                date: date,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeeklyCandlesTable, CandleRow>(table),
                  BaseReferences<_$AppDatabase, $WeeklyCandlesTable, CandleRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyCandlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyCandlesTable,
      CandleRow,
      $$WeeklyCandlesTableFilterComposer,
      $$WeeklyCandlesTableOrderingComposer,
      $$WeeklyCandlesTableAnnotationComposer,
      $$WeeklyCandlesTableCreateCompanionBuilder,
      $$WeeklyCandlesTableUpdateCompanionBuilder,
      (
        CandleRow,
        BaseReferences<_$AppDatabase, $WeeklyCandlesTable, CandleRow>,
      ),
      CandleRow,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String symbol,
  required DateTime addedAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> symbol,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          FavoriteRow,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (
            FavoriteRow,
            BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>,
          ),
          FavoriteRow,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                symbol: symbol,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                symbol: symbol,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, FavoriteRow>(table),
                  BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      FavoriteRow,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (
        FavoriteRow,
        BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>,
      ),
      FavoriteRow,
      PrefetchHooks Function()
    >;
typedef $$CacheMetaTableCreateCompanionBuilder = CacheMetaCompanion Function({
  required String symbol,
  Value<DateTime?> lastFetchedAt,
  Value<String?> logoUrl,
  Value<int> rowid,
});
typedef $$CacheMetaTableUpdateCompanionBuilder = CacheMetaCompanion Function({
  Value<String> symbol,
  Value<DateTime?> lastFetchedAt,
  Value<String?> logoUrl,
  Value<int> rowid,
});

class $$CacheMetaTableFilterComposer
    extends Composer<_$AppDatabase, $CacheMetaTable> {
  $$CacheMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheMetaTable> {
  $$CacheMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheMetaTable> {
  $$CacheMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);
}

class $$CacheMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheMetaTable,
          CacheMetaRow,
          $$CacheMetaTableFilterComposer,
          $$CacheMetaTableOrderingComposer,
          $$CacheMetaTableAnnotationComposer,
          $$CacheMetaTableCreateCompanionBuilder,
          $$CacheMetaTableUpdateCompanionBuilder,
          (
            CacheMetaRow,
            BaseReferences<_$AppDatabase, $CacheMetaTable, CacheMetaRow>,
          ),
          CacheMetaRow,
          PrefetchHooks Function()
        > {
  $$CacheMetaTableTableManager(_$AppDatabase db, $CacheMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMetaCompanion(
                symbol: symbol,
                lastFetchedAt: lastFetchedAt,
                logoUrl: logoUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMetaCompanion.insert(
                symbol: symbol,
                lastFetchedAt: lastFetchedAt,
                logoUrl: logoUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CacheMetaTable, CacheMetaRow>(table),
                  BaseReferences<_$AppDatabase, $CacheMetaTable, CacheMetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheMetaTable,
      CacheMetaRow,
      $$CacheMetaTableFilterComposer,
      $$CacheMetaTableOrderingComposer,
      $$CacheMetaTableAnnotationComposer,
      $$CacheMetaTableCreateCompanionBuilder,
      $$CacheMetaTableUpdateCompanionBuilder,
      (
        CacheMetaRow,
        BaseReferences<_$AppDatabase, $CacheMetaTable, CacheMetaRow>,
      ),
      CacheMetaRow,
      PrefetchHooks Function()
    >;
typedef $$FxRatesTableCreateCompanionBuilder = FxRatesCompanion Function({
  required String day,
  required double eurUsd,
  Value<int> rowid,
});
typedef $$FxRatesTableUpdateCompanionBuilder = FxRatesCompanion Function({
  Value<String> day,
  Value<double> eurUsd,
  Value<int> rowid,
});

class $$FxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get eurUsd => $composableBuilder(
    column: $table.eurUsd,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get eurUsd => $composableBuilder(
    column: $table.eurUsd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<double> get eurUsd =>
      $composableBuilder(column: $table.eurUsd, builder: (column) => column);
}

class $$FxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FxRatesTable,
          FxRateRow,
          $$FxRatesTableFilterComposer,
          $$FxRatesTableOrderingComposer,
          $$FxRatesTableAnnotationComposer,
          $$FxRatesTableCreateCompanionBuilder,
          $$FxRatesTableUpdateCompanionBuilder,
          (FxRateRow, BaseReferences<_$AppDatabase, $FxRatesTable, FxRateRow>),
          FxRateRow,
          PrefetchHooks Function()
        > {
  $$FxRatesTableTableManager(_$AppDatabase db, $FxRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<double> eurUsd = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => FxRatesCompanion(day: day, eurUsd: eurUsd, rowid: rowid),
          createCompanionCallback: ({
            required String day,
            required double eurUsd,
            Value<int> rowid = const Value.absent(),
          }) => FxRatesCompanion.insert(day: day, eurUsd: eurUsd, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FxRatesTable, FxRateRow>(table),
                  BaseReferences<_$AppDatabase, $FxRatesTable, FxRateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FxRatesTable,
      FxRateRow,
      $$FxRatesTableFilterComposer,
      $$FxRatesTableOrderingComposer,
      $$FxRatesTableAnnotationComposer,
      $$FxRatesTableCreateCompanionBuilder,
      $$FxRatesTableUpdateCompanionBuilder,
      (FxRateRow, BaseReferences<_$AppDatabase, $FxRatesTable, FxRateRow>),
      FxRateRow,
      PrefetchHooks Function()
    >;
typedef $$InflationRatesTableCreateCompanionBuilder =
    InflationRatesCompanion Function({Value<int> year, required double rate});
typedef $$InflationRatesTableUpdateCompanionBuilder =
    InflationRatesCompanion Function({Value<int> year, Value<double> rate});

class $$InflationRatesTableFilterComposer
    extends Composer<_$AppDatabase, $InflationRatesTable> {
  $$InflationRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InflationRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $InflationRatesTable> {
  $$InflationRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InflationRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InflationRatesTable> {
  $$InflationRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);
}

class $$InflationRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InflationRatesTable,
          InflationRow,
          $$InflationRatesTableFilterComposer,
          $$InflationRatesTableOrderingComposer,
          $$InflationRatesTableAnnotationComposer,
          $$InflationRatesTableCreateCompanionBuilder,
          $$InflationRatesTableUpdateCompanionBuilder,
          (
            InflationRow,
            BaseReferences<_$AppDatabase, $InflationRatesTable, InflationRow>,
          ),
          InflationRow,
          PrefetchHooks Function()
        > {
  $$InflationRatesTableTableManager(
    _$AppDatabase db,
    $InflationRatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InflationRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InflationRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InflationRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> year = const Value.absent(),
            Value<double> rate = const Value.absent(),
          }) => InflationRatesCompanion(year: year, rate: rate),
          createCompanionCallback: ({
            Value<int> year = const Value.absent(),
            required double rate,
          }) => InflationRatesCompanion.insert(year: year, rate: rate),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InflationRatesTable, InflationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InflationRatesTable,
                    InflationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InflationRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InflationRatesTable,
      InflationRow,
      $$InflationRatesTableFilterComposer,
      $$InflationRatesTableOrderingComposer,
      $$InflationRatesTableAnnotationComposer,
      $$InflationRatesTableCreateCompanionBuilder,
      $$InflationRatesTableUpdateCompanionBuilder,
      (
        InflationRow,
        BaseReferences<_$AppDatabase, $InflationRatesTable, InflationRow>,
      ),
      InflationRow,
      PrefetchHooks Function()
    >;
typedef $$SimulationsTableCreateCompanionBuilder =
    SimulationsCompanion Function({
      Value<int> id,
      required String symbol,
      required String assetName,
      required String paramsJson,
      required String resultJson,
      required DateTime createdAt,
    });
typedef $$SimulationsTableUpdateCompanionBuilder =
    SimulationsCompanion Function({
      Value<int> id,
      Value<String> symbol,
      Value<String> assetName,
      Value<String> paramsJson,
      Value<String> resultJson,
      Value<DateTime> createdAt,
    });

class $$SimulationsTableFilterComposer
    extends Composer<_$AppDatabase, $SimulationsTable> {
  $$SimulationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetName => $composableBuilder(
    column: $table.assetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SimulationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SimulationsTable> {
  $$SimulationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetName => $composableBuilder(
    column: $table.assetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SimulationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SimulationsTable> {
  $$SimulationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get assetName =>
      $composableBuilder(column: $table.assetName, builder: (column) => column);

  GeneratedColumn<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SimulationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SimulationsTable,
          SimulationRow,
          $$SimulationsTableFilterComposer,
          $$SimulationsTableOrderingComposer,
          $$SimulationsTableAnnotationComposer,
          $$SimulationsTableCreateCompanionBuilder,
          $$SimulationsTableUpdateCompanionBuilder,
          (
            SimulationRow,
            BaseReferences<_$AppDatabase, $SimulationsTable, SimulationRow>,
          ),
          SimulationRow,
          PrefetchHooks Function()
        > {
  $$SimulationsTableTableManager(_$AppDatabase db, $SimulationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SimulationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SimulationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SimulationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> assetName = const Value.absent(),
                Value<String> paramsJson = const Value.absent(),
                Value<String> resultJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SimulationsCompanion(
                id: id,
                symbol: symbol,
                assetName: assetName,
                paramsJson: paramsJson,
                resultJson: resultJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String symbol,
                required String assetName,
                required String paramsJson,
                required String resultJson,
                required DateTime createdAt,
              }) => SimulationsCompanion.insert(
                id: id,
                symbol: symbol,
                assetName: assetName,
                paramsJson: paramsJson,
                resultJson: resultJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SimulationsTable, SimulationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SimulationsTable,
                    SimulationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SimulationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SimulationsTable,
      SimulationRow,
      $$SimulationsTableFilterComposer,
      $$SimulationsTableOrderingComposer,
      $$SimulationsTableAnnotationComposer,
      $$SimulationsTableCreateCompanionBuilder,
      $$SimulationsTableUpdateCompanionBuilder,
      (
        SimulationRow,
        BaseReferences<_$AppDatabase, $SimulationsTable, SimulationRow>,
      ),
      SimulationRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InstrumentsTableTableManager get instruments =>
      $$InstrumentsTableTableManager(_db, _db.instruments);
  $$WeeklyCandlesTableTableManager get weeklyCandles =>
      $$WeeklyCandlesTableTableManager(_db, _db.weeklyCandles);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$CacheMetaTableTableManager get cacheMeta =>
      $$CacheMetaTableTableManager(_db, _db.cacheMeta);
  $$FxRatesTableTableManager get fxRates =>
      $$FxRatesTableTableManager(_db, _db.fxRates);
  $$InflationRatesTableTableManager get inflationRates =>
      $$InflationRatesTableTableManager(_db, _db.inflationRates);
  $$SimulationsTableTableManager get simulations =>
      $$SimulationsTableTableManager(_db, _db.simulations);
}
