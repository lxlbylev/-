<?php
// echo $_GET['mail'];
// echo $_GET['password'];


$link = mysqli_connect('127.0.0.1:3306', 'root', '', 'gisit23');
if (!$link) {
    die('Ошибка соединения: ' . mysqli_error());
}

$text = file_get_contents("php://input");
$in = json_decode($text, true);

// echo $text;
// echo $in['name'];
// echo "adwdw";

$result = $link->query("SELECT * FROM users WHERE email= '".$in['email']."'");
$row = $result->fetch_assoc();

if (is_null($row['email']) === TRUE){

    $today = date("Y-m-d");
    $sql2 = "INSERT INTO users (email, password, name, signup_date, status)
    VALUES ('".$in['email']."', '".$in['password']."', '".$in['name']."', '".$today."', 'user')";
    // VALUES ('".$_GET['email']."', '".$_GET['password']."', '".$_GET['name']."', '".$today."')";
    if ($link->query($sql2) === TRUE) {
        echo "Register done!";
    } else {
        echo "Error: " . $sql . "<br>" . $link->error;
    }

} else {
    echo "Already registered";
}
?>



