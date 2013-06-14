﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using DevProLauncher.Network.Enums;
using DevProLauncher.Network.Data;

namespace DevProLauncher.Windows.MessageBoxs
{
    public partial class ChannelList_frm : Form
    {
        public ChannelList_frm()
        {
            InitializeComponent();
            this.FormClosed += RemoveEvents;
            ChannelList.DrawItem += DrawList_Channels;
            Program.ChatServer.ChannelRequest += GenerateChannelList;
            Program.ChatServer.SendPacket(DevServerPackets.ChannelList);
        }

        public void GenerateChannelList(ChannelData[] channels)
        {
            if (InvokeRequired)
            {
                BeginInvoke(new Action<ChannelData[]>(GenerateChannelList), (object)channels);
                return;
            }

            foreach (ChannelData channel in channels)
            {
                ChannelList.Items.Add(channel);
            }
        }
        public void RemoveEvents(object sender, EventArgs e)
        {
            this.FormClosed -= RemoveEvents;
            Program.ChatServer.ChannelRequest -= GenerateChannelList;
        }

        private void DrawList_Channels(object sender, DrawItemEventArgs e)
        {
            var list = (ListBox)sender;
            e.DrawBackground();

            bool selected = ((e.State & DrawItemState.Selected) == DrawItemState.Selected);

            int index = e.Index;
            if (index >= 0 && index < list.Items.Count)
            {
                ChannelData channel = (ChannelData)list.Items[index];
                Graphics g = e.Graphics;

                g.FillRectangle((selected) ? (Program.Config.ColorBlindMode ? new SolidBrush(Color.Black) : new SolidBrush(Color.Blue)) : new SolidBrush(Program.Config.ChatBGColor.ToColor()), e.Bounds);

                //// Print text
                g.DrawString(channel.name + " (" + channel.userCount + ")", e.Font,
                    (selected) ? Brushes.White : Brushes.Black ,
                    list.GetItemRectangle(index).Location);
            }

            e.DrawFocusRectangle();
        }

        private void JoinBtn_Click(object sender, EventArgs e)
        {
            if (ChannelList.SelectedIndex == -1)
                return;

            Program.ChatServer.SendPacket(DevServerPackets.JoinChannel, ((ChannelData)ChannelList.SelectedItem).name);
            DialogResult = DialogResult.OK;
        }

        private void CreateBtn_Click(object sender, EventArgs e)
        {
            Input_frm input = new Input_frm("Create Channel", "Enter Channel Name", "Create", "Cancel");
            if (input.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                Program.ChatServer.SendPacket(DevServerPackets.JoinChannel, input.InputBox.Text);
                DialogResult = DialogResult.OK;
            }
        }
    }
}
