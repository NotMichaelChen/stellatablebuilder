type ClearLevel* = object
  symbol*: char
  title*: string

const Easy* = ClearLevel(symbol: 'E', title: "EASY")
const Normal* = ClearLevel(symbol: 'N', title: "NORMAL")
const Hard* = ClearLevel(symbol: 'H', title: "HARD")
const FullCombo* = ClearLevel(symbol: 'F', title: "FULLCOMBO")

const AllClearLevel* = [Easy, Normal, Hard, FullCombo]