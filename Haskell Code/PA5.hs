-- PA5.hs  INCOMPLETE
-- Daniel Lind
-- 27 Mar 2018
--
-- CS F331
-- Solutions to Assignment 5 Exercise B

module PA5 where


-- collatzCounts
getCount'::Integer->Integer->Integer
getCount' item_num count
                 | item_num==1           = count
                 | mod item_num 2 == 0 = getCount' (div item_num 2) count+1
                 | mod item_num 2 /= 0 = getCount' (3*item_num+1) count+1
getCount::Integer->Integer
getCount item_num
                 | item_num==0           = 0
                 | item_num==1           = 1
                 | mod item_num 2 == 0 = getCount' (div item_num 2) 1
                 | mod item_num 2 /= 0 = getCount' (3*item_num+1) 1
collatzCounts :: [Integer]
collatzCounts' = map getCount[2..]
collatzCounts = 0:collatzCounts'



-- findList
findList' :: Eq a => [a] -> [a] -> Int -> Maybe Int
findList' list1 list2 index
    | head list1 == list2!!index = do
        if (take (length list1) (drop (index) list2)) == list1
            then Just index
                else Nothing
    | head list1 /= list2!!index = findList' list1 list2 (index+1)
    | otherwise = Nothing    
findList :: Eq a => [a] -> [a] -> Maybe Int
findList [] list2 = Just 0
findList list1 list2
    | head list1 == list2!!0 = do
        if (take (length list1) (drop 1 list2)) == list1
            then Just 0
                else Nothing
    | head list1 /= list2!!0 = findList' list1 list2 1
    | otherwise = Nothing


-- operator ##
checkList lhlist rhlist index amt
   | (length lhlist == (index) || length rhlist == (index)) = amt
   | (lhlist!!index) == (rhlist!!index) = checkList lhlist rhlist (index+1) (amt+1)
   | (lhlist!!index /= rhlist!!index) = checkList lhlist rhlist (index+1) (amt)
   | otherwise = -1
checkList lhlist rhlist index 1 = checkList lhlist rhlist index 2
(##) :: Eq a => [a] -> [a] -> Int
[] ## _ = 0
lhlist ## rhlist = checkList lhlist rhlist 0 0

-- filterAB
filterAB' bool_Func [] list2 index = []
filterAB' bool_Func [] [] index = []
filterAB' bool_Func list1 [] index = []
filterAB' bool_Func list1 list2 index
   | (bool_Func (head list1)) = filterAB' bool_Func (tail list1) (list2) (index+1)
   | not (bool_Func (head list1)) = filterAB' bool_Func (tail list1) (drop index list2)index
   
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB bool_Func [] list2 = list2
filterAB bool_Func [] [] = []
filterAB bool_Func list1 [] = []
filterAB bool_Func list1 list2
   | (bool_Func (head list1)) = filterAB' bool_Func (tail list1) list2 1
   | not (bool_Func (head list1)) = filterAB bool_Func (tail list1) (tail list2)


-- sumEvenOdd
sumEvenOdd :: Num a => [a] -> (a, a)
{-
  The assignment requires sumEvenOdd to be written using a fold.
  Something like this:

    sumEvenOdd xs = fold* ... xs where
        ...

  Above, "..." should be replaced by other code. The "fold*" must be
  one of the following: foldl, foldr, foldl1, foldr1.
-}
sumEvenOdd _ = (0, 0)  -- DUMMY; REWRITE THIS!!!

