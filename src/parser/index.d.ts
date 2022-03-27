export type Statement = Aggregator | AmountMultiplier | Dice;

declare interface AmountMultiplier {
  type: 'multiplier';
  amount: number;
  assert?: Assert;
  modifiers?: Modifier[];
  dice: Dice;
}

export declare interface Dice {
  type: 'dice';
  sides: number;
  assert?: Assert;
  modifiers?: Modifier[];
}

export type BinaryModifierOperator = '+' | '-' | '*' | '/' | '%';
export type UnaryModifierOperator = '~';
export type ModifierOperator = BinaryModifierOperator | UnaryModifierOperator;

export type BinaryModifier = {
  op: BinaryModifierOperator;
  value: number;
}

export type UnaryModifier = {
  op: UnaryModifierOperator;
};

export type Modifier = BinaryModifier | UnaryModifier;

type RangeSetOperator = '==' | '!=';
type CompareOperator = '<' | '<=' | '==' | '!=' | '>' | '>=';

export declare interface RangeAssert {
  type: 'range';
  op: RangeSetOperator;
  values: [number, number];
  closed: [boolean, boolean];
}

declare interface GeneralTermFormula {
  a: number,
  k: number,
};

export declare interface SetAssert {
  type: 'set';
  op: RangeSetOperator;
  values: number[] | [GeneralTermFormula, ...number[]];
}

export declare interface CompareAssert {
  type: 'compare';
  op: CompareOperator;
  value: number;
}

export type Assert = RangeAssert | SetAssert | CompareAssert;
export type AggregatorParamList = Array<Statement | number | boolean>

export declare interface Aggregator {
  type: 'aggregator';
  aggregator: string;
  params: AggregatorParamList;
}

export declare function parse(input: string): Statement[];
