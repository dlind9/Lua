-- PA5.hs  INCOMPLETE
-- Glenn G. Chappell
-- 21 Mar 2018
--
-- For CS F331 / CSCE A331 Spring 2018
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
findList :: Eq a => [a] -> [a] -> Maybe Int
findList list1 list2 = do  -- DUMMY; REWRITE THIS!!!
    | head list1 == list2!!index =


-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
_ ## _ = 42  -- DUMMY; REWRITE THIS!!!


-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB _ _ bs = bs  -- DUMMY; REWRITE THIS!!!


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
