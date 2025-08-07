<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('menus', function (Blueprint $table) {
            $table->id('item_id');
            $table->unsignedBigInteger('restaurant_id'); // Match `unsignedBigInteger`
            $table->foreign('restaurant_id')
                ->references('id')
                ->on('restaurants')
                ->onDelete('cascade');
            $table->string('name');
            $table->string('type');
            $table->text('description')->nullable();
            $table->float('price');
            $table->string('image_url')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('menus');
    }
};
