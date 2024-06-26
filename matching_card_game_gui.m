function matching_card_game
    symbols = [1, 2, 3, 4, 5, 6, 7, 8];
    symbols = [symbols, symbols]; 
    symbols = symbols(randperm(length(symbols))); 

    fig = figure('Name', 'Matching Card Game', 'NumberTitle', 'off', ...
                 'MenuBar', 'none', 'ToolBar', 'none', ...
                 'CloseRequestFcn', @close_game);

    imgDir = 'images/';
    imgFiles = {'img1.png', 'img2.png', 'img3.png', 'img4.png', ...
                'img5.png', 'img6.png', 'img7.png', 'img8.png'};
    images = cell(1, 8);
    for k = 1:8
        img = imread(fullfile(imgDir, imgFiles{k}));
        img = imresize(img, [100, 100]); 
        images{k} = img;
    end

    buttons = gobjects(4, 4);
    for i = 1:4
        for j = 1:4
            buttons(i, j) = uicontrol('Style', 'pushbutton', 'String', '', ...
                                      'Units', 'normalized', ...
                                      'Position', [(j-1)/4, 1-i/4, 1/4, 1/4], ...
                                      'Callback', {@card_callback, i, j}, ...
                                      'UserData', struct('image', images{symbols((i-1)*4 + j)}, 'value', symbols((i-1)*4 + j)));
        end
    end

    score1_text = uicontrol('Style', 'text', 'String', 'Player 1: 0', ...
                            'Units', 'normalized', 'Position', [0, 0, 0.25, 0.05], ...
                            'FontSize', 12);
    score2_text = uicontrol('Style', 'text', 'String', 'Player 2: 0', ...
                            'Units', 'normalized', 'Position', [0.75, 0, 0.25, 0.05], ...
                            'FontSize', 12);

    player_turn_text = uicontrol('Style', 'text', 'String', 'Player 1''s Turn', ...
                               'Units', 'normalized', 'Position', [0.25, 0, 0.5, 0.05], ...
                               'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', [0 0.5 0]);

    setappdata(fig, 'symbols', reshape(symbols, [4, 4]));
    setappdata(fig, 'first_card', []);
    setappdata(fig, 'second_card', []);
    setappdata(fig, 'found_pairs', zeros(4, 4));
    setappdata(fig, 'score1', 0);
    setappdata(fig, 'score2', 0);
    setappdata(fig, 'current_player', 1);
    setappdata(fig, 'score1_text', score1_text);
    setappdata(fig, 'score2_text', score2_text);
    setappdata(fig, 'buttons', buttons);
    setappdata(fig, 'player_turn_text', player_turn_text);
end

function card_callback(src, ~, i, j)
    fig = ancestor(src, 'figure');
    symbols = getappdata(fig, 'symbols');
    found_pairs = getappdata(fig, 'found_pairs');
    current_player = getappdata(fig, 'current_player');
    buttons = getappdata(fig, 'buttons');

    if found_pairs(i, j)
        return;
    end

    data = get(src, 'UserData');
    set(src, 'CData', data.image);

    first_card = getappdata(fig, 'first_card');
    if isempty(first_card)
        setappdata(fig, 'first_card', [i, j]);
    else
        second_card = [i, j];
        first_data = get(buttons(first_card(1), first_card(2)), 'UserData');
        second_data = get(buttons(second_card(1), second_card(2)), 'UserData');
        if first_data.value == second_data.value
            found_pairs(first_card(1), first_card(2)) = 1;
            found_pairs(second_card(1), second_card(2)) = 1;
            setappdata(fig, 'found_pairs', found_pairs);
            if current_player == 1
                score1 = getappdata(fig, 'score1') + 1;
                setappdata(fig, 'score1', score1);
                set(getappdata(fig, 'score1_text'), 'String', ['Player 1: ' num2str(score1)]);
            else
                score2 = getappdata(fig, 'score2') + 1;
                setappdata(fig, 'score2', score2);
                set(getappdata(fig, 'score2_text'), 'String', ['Player 2: ' num2str(score2)]);
            end
            [y, Fs] = audioread(fullfile('audio', 'sec.mp3')); % <-- تغییر داده شد
            sound(y, Fs);
        else
            pause(0.5);
            set(src, 'CData', []);
            set(buttons(first_card(1), first_card(2)), 'CData', []);
            current_player = 3 - current_player;
            setappdata(fig, 'current_player', current_player);
            [y, Fs] = audioread(fullfile('audio', 'wor.mp3')); 
            sound(y, Fs);

        end
        setappdata(fig, 'first_card', []);
    end

    player_turn_text = getappdata(fig, 'player_turn_text');
    if current_player == 1
        color = [0 0.5 0]; 
    else
        color = [0.8 0 0]; 
    end
    set(player_turn_text, 'String', ['Player ' num2str(current_player) '''s Turn'], ...
                        'ForegroundColor', color);

    if all(found_pairs(:))
        msgbox(['Game Over! Final Scores - Player 1: ' num2str(getappdata(fig, 'score1')) ...
                ', Player 2: ' num2str(getappdata(fig, 'score2'))], 'Congratulations');
    end
end

function close_game(fig, ~)
    delete(fig);
end