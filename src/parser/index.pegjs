{
  function removeNullish(o) {
    for (const k in o) {
      if (Object.prototype.hasOwnProperty.call(o, k) && o[k] == null) {
        Reflect.deleteProperty(o, k);
      }
    }

    return o;
  }
}

Statements
  = statement:(Statement) rest:(" "+ (Statement))* {
    return [statement, ...rest]
      .flat(Infinity)
      .filter((x) => x !== ' ');
  }

Statement
  = Aggregator
  / AmountMulitplier

AmountMulitplier
  = amount:PositiveInteger "(" dice:Dice innerModifiers:Modifiers? ")" modifiers:Modifiers? assert:Assert? {
    return removeNullish({
      type: 'multiplier',
      amount,
      assert,
      modifiers,
      dice: removeNullish(Object.assign(dice, {
        modifiers: innerModifiers,
      })),
    })
  }
  / amount:PositiveInteger? dice:Dice modifiers:Modifiers? assert:Assert? {
    if (amount == null || amount === 1) {
      return removeNullish(Object.assign(
        dice,
        {
          modifiers,
          assert,
        },
      ));
    }

    return removeNullish({
      type: 'multiplier',
      amount,
      assert,
      modifiers,
      dice,
    })
  }

Dice
  = "D"i sides:PositiveInteger {
    return {
      type: 'dice',
      sides,
    };
  }

Modifiers
  = mods:(Modifier+) {
    return Object.assign(
      mods,
      {
        text: text(),
      },
    );
  }

Modifier
  = BinaryModifier
  / UnaryModifier

BinaryModifier
  = op:[-+*/%] value:PositiveInteger {
    return { op, value };
  }

UnaryModifier
  = op:[~] {
    return { op };
  }

Assert
  = RangeAssert / SetAssert / CompareAssert

RangeAssert
  = op:RangeSetOperator lc:("[" / "(") lb:Integer "," rb:Integer rc:("]" / ")") {
    return {
      type: 'range',
      op,
      range: {
        left: {
          value: lb,
          closed: lc === '[',
        },
        right: {
          value: rb,
          closed: rc === ']',
        },
      },
    };
  }

SetAssert
  = op:RangeSetOperator "{" items:IntegerCommaList "}" {
    return {
      type: 'set',
      op,
      values,
    };
  }

CompareAssert
  = op:CompareOperator value:Integer {
    return {
      type: 'compare',
      op,
      value,
    };
  }

RangeSetOperator
  = "==" / "!="

CompareOperator
  = "!=" / "==" / ">=" / "<=" / ">" / "<"

Aggregator = name:Word "(" params:AggregatorParamList? ")" asser:Assert? {
  return removeNullish({
    type: 'aggregator',
    name,
    assert,
    params: params ?? [],
  });
}

AggregatorParam
  = Statement
  / Number

AggregatorParamList
  = first:AggregatorParam rest:(" " AggregatorParam)* {
    return [first, rest]
      .flat(Infinity)
      .filter((x) => x !== ' ');
  }

IntegerCommaList
  = s:Integer r:("," Integer)* {
    return [s, ...r].flat(Infinity).filter((x) => x != ',');
  }

Number
  = Float
  / Integer

Integer
  = NegativeInteger
  / PositiveInteger
  / number:"0" {
    return 0;
  }

NegativeInteger
  = "-" number:PositiveInteger {
    return -number;
  }

Float
  = sign:"-"? digits:([1-9][0-9]*)? "." decimal:([0-9]+) {
    return (digits?.flat() ?? [0]).concat('.', decimal.flat()).join('') * (sign ? -1 : 1);
  }

PositiveInteger
  = digits:([1-9][0-9]*) {
    return parseInt(digits.flat().join(''), 10);
  }

Word
  = chars:([a-zA-Z_$][0-9a-zA-Z_$]*) {
    return chars.flat().join('');
  }
