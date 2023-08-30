#!/bin/bash

sendpoint=true

while getopts "u:" flag
do
    case "${flag}" in
        u) sendpoint=${OPTARG};;
    esac
done

echo "Sendpoint: $sendpoint";

id_turtlebot_docker='576c09022dcbb78037a7db60c38ca11f2fa42fe108c6a1b72536c2ed210260c1'
id_huggingface_docker='56a4b691e9c9ebd5b1df84595e3eb236138776efadf1bb61c99c1964433a005f'

while :
do
    echo -e "\nWrite the text request: "
    read text
    echo "Text: $text"

    if [ "$text" == "rotate" ]; then
        echo "How many degrees I should rotate (clockwise): "
        read degrees

        docker exec -it $id_turtlebot_docker /bin/bash -c "
                . /opt/ros/noetic/setup.bash && 
                . /home/rosuser/catkin_ws/devel/setup.bash && 
                export ROS_MASTER_URI=http://localhost:11311 &&
                rosrun beginner_tutorials navigation.py $degrees" 
    else

        docker exec -it $id_turtlebot_docker /bin/bash -c "
            . /opt/ros/noetic/setup.bash && 
            . /home/rosuser/catkin_ws/devel/setup.bash && 
            export ROS_MASTER_URI=http://localhost:11311 &&
            rosrun beginner_tutorials listener_simu.py" 

        docker exec -it $id_huggingface_docker python /app/zero_shot.py $text
        theta=$?

        if [ $sendpoint == "true" ]; then
            echo "Sending Goal"
            docker exec -it $id_turtlebot_docker /bin/bash -c "
                . /opt/ros/noetic/setup.bash && 
                . /home/rosuser/catkin_ws/devel/setup.bash && 
                export ROS_MASTER_URI=http://localhost:11311 &&
                rosrun beginner_tutorials gotoapoint_simu.py $theta" 
        fi
    fi    

    

done
