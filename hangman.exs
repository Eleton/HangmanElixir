defmodule Hangman do
  def countLetters(str) do
    str
      |> String.graphemes()
      |> Enum.sort()
      |> countLetters(%{})
  end

  def countLetters([a], map), do: Map.update(map, a, 1, fn count -> count + 1 end)
  def countLetters([a,a|tail], map) do
    countLetters([a|tail], Map.update(map, a, 1, fn count -> count + 1 end))
  end
  def countLetters([a,b|tail], map), do: countLetters([b|tail], Map.update(map, a, 1, fn count -> count + 1 end))

  def startCompareWords(guessWord, lexicalWord) do
    compareWords(String.graphemes(guessWord), String.graphemes(lexicalWord))
  end
  def compareWords(["_"|guessRest], [_|lexicalRest]), do: compareWords(guessRest, lexicalRest)
  def compareWords([a|guessRest], [a|lexicalRest]), do: compareWords(guessRest, lexicalRest)
  def compareWords([], []), do: true
  def compareWords(_, _), do: false

  def putLettersInGuess([], _, guess), do: Enum.join(guess)
  def putLettersInGuess([num|placements], character, guess) do
    putLettersInGuess(placements, character, List.replace_at(guess, num-1, character))
  end


  def getAnswer(wordList, guess, [guessLetter|guessRest]) do
    answer = IO.gets("Does the word contain letter #{guessLetter}? y/n\n")
    case String.trim(answer) do
      "y" ->
        IO.puts(guess)
        placements = IO.gets("Where should the letter be placed? (comma-separated list of numbers)\n")
        placements = placements
          |> String.trim()
          |> String.split(",")
          |> Enum.map(fn(num) -> String.to_integer(String.trim(num)) end)
        
        newGuess = putLettersInGuess(placements, guessLetter, String.graphemes(guess))
        IO.puts("Current state: " <> newGuess)
        gameLoop(wordList, newGuess)
      "n" ->
        IO.puts("Too bad!")
        getAnswer(wordList, guess, guessRest)
      _ ->
        IO.puts("What?")
        getAnswer(wordList, guess, [guessLetter|guessRest])
    end
  end

  def gameLoop(wordList, guess) do
    if String.contains?(guess, "_") do
      guessList = wordList
        |> Enum.filter(fn(w) -> Hangman.startCompareWords(guess, w) end)
        |> Enum.reduce(fn(w, acc) -> acc <> w end)
        |> Hangman.countLetters()
        |> Map.to_list()
        |> Enum.sort(fn({_, v1}, {_, v2}) -> v1 >= v2 end)
        |> Enum.map(fn({char, _}) -> char end)
        |> Enum.filter(fn(char) -> not String.contains?(guess, char) end)

      getAnswer(wordList, guess, guessList)
    else
      IO.puts("Woho, I'm done! Answer is \"#{guess}\"!")
    end
  end
    
end

content = File.read! "./words_alpha.txt"
length = IO.gets("How long is your word?\n")
length = String.to_integer(String.trim(length))
filteredWords = content
  |> String.split("\r\n")
  |> Enum.filter(fn(w) -> String.length(w) == length end)

Hangman.gameLoop(filteredWords, String.duplicate("_", length))